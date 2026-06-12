package com.medicare.dao;

import com.medicare.config.DBConnection;

import java.sql.*;
import java.util.*;

public class OrderIssueDAO {
    private static volatile boolean schemaChecked = false;

    public OrderIssueDAO() {
        ensureSchema();
    }

    private static synchronized void ensureSchema() {
        if (schemaChecked) return;

        String sql = "CREATE TABLE IF NOT EXISTS order_issues (" +
                "issue_id INT AUTO_INCREMENT PRIMARY KEY," +
                "order_id INT NOT NULL," +
                "user_id INT NOT NULL," +
                "issue_type VARCHAR(80) NOT NULL DEFAULT 'Delivery Problem'," +
                "message TEXT NOT NULL," +
                "issue_status ENUM('Open','In Review','Resolved','Closed') NOT NULL DEFAULT 'Open'," +
                "admin_response TEXT," +
                "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP," +
                "responded_at TIMESTAMP NULL," +
                "FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE," +
                "FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE" +
                ")";

        try (Connection con = DBConnection.getConnection();
             Statement st = con.createStatement()) {
            st.executeUpdate(sql);
            schemaChecked = true;
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public boolean addIssue(int userId, int orderId, String issueType, String message) {
        if (isBlank(message)) return false;

        String sql = "INSERT INTO order_issues(order_id,user_id,issue_type,message) " +
                "SELECT ?,?,?,? FROM orders WHERE order_id=? AND user_id=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            ps.setInt(2, userId);
            ps.setString(3, safeIssueType(issueType));
            ps.setString(4, message.trim());
            ps.setInt(5, orderId);
            ps.setInt(6, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public Map<Integer,List<Map<String,Object>>> getByUserGrouped(int userId) {
        Map<Integer,List<Map<String,Object>>> grouped = new LinkedHashMap<>();
        String sql = "SELECT oi.*,u.name AS customer_name FROM order_issues oi " +
                "JOIN users u ON oi.user_id=u.user_id WHERE oi.user_id=? ORDER BY oi.created_at DESC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String,Object> row = mapIssue(rs);
                Integer orderId = (Integer) row.get("orderId");
                grouped.computeIfAbsent(orderId, k -> new ArrayList<>()).add(row);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return grouped;
    }

    public List<Map<String,Object>> getAll() {
        List<Map<String,Object>> issues = new ArrayList<>();
        String sql = "SELECT oi.*,u.name AS customer_name,u.email AS customer_email,o.order_status,o.delivery_method " +
                "FROM order_issues oi JOIN users u ON oi.user_id=u.user_id JOIN orders o ON oi.order_id=o.order_id " +
                "ORDER BY CASE oi.issue_status WHEN 'Open' THEN 1 WHEN 'In Review' THEN 2 WHEN 'Resolved' THEN 3 ELSE 4 END, oi.created_at DESC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) issues.add(mapIssue(rs));
        } catch (Exception e) {
            e.printStackTrace();
        }
        return issues;
    }

    public boolean updateResponse(int issueId, String issueStatus, String adminResponse) {
        if (!isAllowedStatus(issueStatus)) return false;

        String sql = "UPDATE order_issues SET issue_status=?, admin_response=?, responded_at=NOW() WHERE issue_id=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, issueStatus);
            ps.setString(2, isBlank(adminResponse) ? "" : adminResponse.trim());
            ps.setInt(3, issueId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public Map<String,Object> analytics() {
        Map<String,Object> a = new HashMap<>();
        try (Connection con = DBConnection.getConnection();
             Statement st = con.createStatement()) {
            ResultSet rs = st.executeQuery("SELECT COUNT(*) c FROM order_issues WHERE issue_status IN ('Open','In Review')");
            if (rs.next()) a.put("activeIssues", rs.getInt("c"));
        } catch (Exception e) {
            e.printStackTrace();
        }
        return a;
    }

    private Map<String,Object> mapIssue(ResultSet rs) throws SQLException {
        Map<String,Object> row = new HashMap<>();
        row.put("issueId", rs.getInt("issue_id"));
        row.put("orderId", rs.getInt("order_id"));
        row.put("userId", rs.getInt("user_id"));
        row.put("issueType", rs.getString("issue_type"));
        row.put("message", rs.getString("message"));
        row.put("issueStatus", rs.getString("issue_status"));
        row.put("adminResponse", rs.getString("admin_response"));
        row.put("createdAt", rs.getString("created_at"));
        row.put("respondedAt", rs.getString("responded_at"));
        try { row.put("customerName", rs.getString("customer_name")); } catch (SQLException ignored) { row.put("customerName", ""); }
        try { row.put("customerEmail", rs.getString("customer_email")); } catch (SQLException ignored) { row.put("customerEmail", ""); }
        try { row.put("orderStatus", rs.getString("order_status")); } catch (SQLException ignored) { row.put("orderStatus", ""); }
        try { row.put("deliveryMethod", rs.getString("delivery_method")); } catch (SQLException ignored) { row.put("deliveryMethod", ""); }
        return row;
    }

    private String safeIssueType(String issueType) {
        if ("Order Received".equals(issueType)
                || "Order Not Received".equals(issueType)
                || "Delivery Problem".equals(issueType)
                || "Medicine Problem".equals(issueType)
                || "Other".equals(issueType)) {
            return issueType;
        }
        return "Delivery Problem";
    }

    private boolean isAllowedStatus(String status) {
        return "Open".equals(status) || "In Review".equals(status)
                || "Resolved".equals(status) || "Closed".equals(status);
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }
}
