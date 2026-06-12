package com.medicare.dao;

import com.medicare.config.DBConnection;

import java.sql.*;
import java.util.*;

public class CartOrderDAO {
    private static volatile boolean schemaChecked = false;
    private static final String DEFAULT_DELIVERY_METHOD = MedicineDAO.STANDARD_MEDICAL_COURIER;

    public CartOrderDAO() {
        ensureOrderSchema();
    }

    private static synchronized void ensureOrderSchema() {
        if (schemaChecked) return;

        try (Connection con = DBConnection.getConnection();
             Statement st = con.createStatement()) {
            boolean addedStatus = addColumnIfMissing(con, st, "order_items", "item_status",
                    "ALTER TABLE order_items ADD COLUMN item_status ENUM('Pending','Approved','Completed','Cancelled') NOT NULL DEFAULT 'Pending' AFTER price");
            if (addedStatus) {
                st.executeUpdate("UPDATE order_items oi JOIN orders o ON oi.order_id=o.order_id SET oi.item_status=o.order_status");
            }
            addColumnIfMissing(con, st, "orders", "delivery_method",
                    "ALTER TABLE orders ADD COLUMN delivery_method VARCHAR(80) NOT NULL DEFAULT '" + DEFAULT_DELIVERY_METHOD + "' AFTER order_status");
            addColumnIfMissing(con, st, "medicines", "delivery_methods",
                    "ALTER TABLE medicines ADD COLUMN delivery_methods VARCHAR(180) NOT NULL DEFAULT '" + MedicineDAO.DEFAULT_DELIVERY_METHODS + "' AFTER image");
            addColumnIfMissing(con, st, "order_items", "expected_delivery_at",
                    "ALTER TABLE order_items ADD COLUMN expected_delivery_at DATETIME NULL AFTER item_status");
            schemaChecked = true;
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private static boolean addColumnIfMissing(Connection con, Statement st, String tableName, String columnName, String alterSql) throws SQLException {
        try (ResultSet rs = con.getMetaData().getColumns(con.getCatalog(), null, tableName, columnName)) {
            if (!rs.next()) {
                st.executeUpdate(alterSql);
                return true;
            }
        }
        return false;
    }

    public boolean addToCart(int userId, int medicineId, int qty) {
        if (qty <= 0) return false;

        try (Connection con = DBConnection.getConnection()) {
            int stock = getStock(con, medicineId);
            if (stock < qty) return false;

            try (PreparedStatement check = con.prepareStatement("SELECT cart_id, quantity FROM cart WHERE user_id=? AND medicine_id=?")) {
                check.setInt(1, userId);
                check.setInt(2, medicineId);
                ResultSet rs = check.executeQuery();

                if (rs.next()) {
                    int cartId = rs.getInt("cart_id");
                    int newQty = rs.getInt("quantity") + qty;
                    if (newQty > stock) return false;

                    try (PreparedStatement ps = con.prepareStatement("UPDATE cart SET quantity=? WHERE cart_id=? AND user_id=?")) {
                        ps.setInt(1, newQty);
                        ps.setInt(2, cartId);
                        ps.setInt(3, userId);
                        return ps.executeUpdate() > 0;
                    }
                }
            }

            try (PreparedStatement ps = con.prepareStatement("INSERT INTO cart(user_id,medicine_id,quantity) VALUES(?,?,?)")) {
                ps.setInt(1, userId);
                ps.setInt(2, medicineId);
                ps.setInt(3, qty);
                return ps.executeUpdate() > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    private int getStock(Connection con, int medicineId) throws SQLException {
        String sql = "SELECT m.quantity FROM medicines m JOIN users u ON m.created_by=u.user_id " +
                "WHERE m.medicine_id=? AND u.role='pharmacist' AND u.approval_status='approved'";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, medicineId);
            ResultSet rs = ps.executeQuery();
            return rs.next() ? rs.getInt("quantity") : -1;
        }
    }

    public boolean updateCart(int cartId, int userId, int qty) {
        if (qty <= 0) return removeCart(cartId, userId);

        String checkSql = "SELECT m.quantity AS stock FROM cart c JOIN medicines m ON c.medicine_id=m.medicine_id " +
                "JOIN users u ON m.created_by=u.user_id " +
                "WHERE c.cart_id=? AND c.user_id=? AND u.role='pharmacist' AND u.approval_status='approved'";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement check = con.prepareStatement(checkSql)) {
            check.setInt(1, cartId);
            check.setInt(2, userId);
            ResultSet rs = check.executeQuery();
            if (!rs.next() || qty > rs.getInt("stock")) return false;

            try (PreparedStatement ps = con.prepareStatement("UPDATE cart SET quantity=? WHERE cart_id=? AND user_id=?")) {
                ps.setInt(1, qty);
                ps.setInt(2, cartId);
                ps.setInt(3, userId);
                return ps.executeUpdate() > 0;
            }
        } catch(Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean removeCart(int cartId, int userId) {
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement("DELETE FROM cart WHERE cart_id=? AND user_id=?")) {
            ps.setInt(1, cartId);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch(Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<Map<String,Object>> getCart(int userId) {
        try (Connection con = DBConnection.getConnection()) {
            return getCart(con, userId, false);
        } catch(Exception e) {
            e.printStackTrace();
            return new ArrayList<>();
        }
    }

    private List<Map<String,Object>> getCart(Connection con, int userId, boolean forUpdate) throws SQLException {
        List<Map<String,Object>> list = new ArrayList<>();
        String sql = "SELECT c.cart_id,c.quantity,m.medicine_id,m.name,m.price,m.category,COALESCE(NULLIF(m.image,''),'medicine.svg') AS image,m.delivery_methods,m.quantity AS stock, " +
                "CASE WHEN u.role='pharmacist' AND u.approval_status='approved' THEN 1 ELSE 0 END AS orderable " +
                "FROM cart c JOIN medicines m ON c.medicine_id=m.medicine_id " +
                "LEFT JOIN users u ON m.created_by=u.user_id WHERE c.user_id=? ORDER BY c.cart_id DESC";
        if (forUpdate) sql += " FOR UPDATE";

        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            while(rs.next()) {
                Map<String,Object> row = new HashMap<>();
                int qty = rs.getInt("quantity");
                double price = rs.getDouble("price");
                row.put("cartId", rs.getInt("cart_id"));
                row.put("medicineId", rs.getInt("medicine_id"));
                row.put("name", rs.getString("name"));
                row.put("category", rs.getString("category"));
                row.put("image", rs.getString("image"));
                row.put("deliveryMethods", rs.getString("delivery_methods"));
                row.put("price", price);
                row.put("quantity", qty);
                row.put("stock", rs.getInt("stock"));
                row.put("orderable", rs.getInt("orderable") == 1);
                row.put("subtotal", price * qty);
                list.add(row);
            }
        }
        return list;
    }

    public boolean placeOrder(int userId) {
        return placeOrder(userId, DEFAULT_DELIVERY_METHOD);
    }

    public boolean placeOrder(int userId, String deliveryMethod) {
        String normalizedDeliveryMethod = normalizeDeliveryMethod(deliveryMethod);
        if (isBlank(normalizedDeliveryMethod)) return false;

        try (Connection con = DBConnection.getConnection()) {
            con.setAutoCommit(false);

            List<Map<String,Object>> cart = getCart(con, userId, true);
            if(cart.isEmpty()) {
                con.rollback();
                return false;
            }

            double total = 0;
            for(Map<String,Object> item : cart) {
                int qty = (int)item.get("quantity");
                int stock = (int)item.get("stock");
                boolean orderable = (boolean)item.get("orderable");
                String availableDeliveryMethods = String.valueOf(item.get("deliveryMethods"));
                if (!orderable || qty <= 0 || qty > stock || !deliveryMethodAllowed(availableDeliveryMethods, normalizedDeliveryMethod)) {
                    con.rollback();
                    return false;
                }
                total += (double)item.get("subtotal");
            }

            int orderId;
            try (PreparedStatement orderPs = con.prepareStatement(
                    "INSERT INTO orders(user_id,total_amount,order_status,delivery_method) VALUES(?,?,?,?)",
                    Statement.RETURN_GENERATED_KEYS
            )) {
                orderPs.setInt(1, userId);
                orderPs.setDouble(2, total);
                orderPs.setString(3, "Pending");
                orderPs.setString(4, normalizedDeliveryMethod);
                orderPs.executeUpdate();

                ResultSet keys = orderPs.getGeneratedKeys();
                if (!keys.next()) {
                    con.rollback();
                    return false;
                }
                orderId = keys.getInt(1);
            }

            for(Map<String,Object> item : cart) {
                int medicineId = (int)item.get("medicineId");
                int qty = (int)item.get("quantity");
                double price = (double)item.get("price");

                try (PreparedStatement itemPs = con.prepareStatement(
                        "INSERT INTO order_items(order_id,medicine_id,quantity,price,item_status) VALUES(?,?,?,?,?)")) {
                    itemPs.setInt(1, orderId);
                    itemPs.setInt(2, medicineId);
                    itemPs.setInt(3, qty);
                    itemPs.setDouble(4, price);
                    itemPs.setString(5, "Pending");
                    itemPs.executeUpdate();
                }

                try (PreparedStatement stockPs = con.prepareStatement("UPDATE medicines SET quantity=quantity-? WHERE medicine_id=? AND quantity>=?")) {
                    stockPs.setInt(1, qty);
                    stockPs.setInt(2, medicineId);
                    stockPs.setInt(3, qty);
                    if (stockPs.executeUpdate() == 0) {
                        con.rollback();
                        return false;
                    }
                }
            }

            try (PreparedStatement clear = con.prepareStatement("DELETE FROM cart WHERE user_id=?")) {
                clear.setInt(1, userId);
                clear.executeUpdate();
            }

            con.commit();
            return true;
        } catch(Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    private String normalizeDeliveryMethod(String deliveryMethod) {
        if (deliveryMethod == null) return "";

        String method = deliveryMethod.trim();
        if (MedicineDAO.STANDARD_MEDICAL_COURIER.equals(method)
                || MedicineDAO.EXPRESS_MEDICAL_COURIER.equals(method)
                || MedicineDAO.MEDICARE_DELIVERY_SERVICE.equals(method)) {
            return method;
        }
        return "";
    }

    private boolean deliveryMethodAllowed(String deliveryMethods, String selectedMethod) {
        if (isBlank(deliveryMethods) || isBlank(selectedMethod)) return false;

        String[] methods = deliveryMethods.split(",");
        for (String method : methods) {
            if (selectedMethod.equals(method.trim())) return true;
        }
        return false;
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }

    public List<Map<String,Object>> getOrders(int userId, boolean all) {
        List<Map<String,Object>> list = new ArrayList<>();
        String sql = "SELECT o.order_id,u.name AS customer_name,o.total_amount,o.order_status,o.order_date,o.delivery_method, " +
                "COALESCE(GROUP_CONCAT(CASE WHEN oi.item_id IS NULL THEN NULL ELSE CONCAT(m.name,' x ',oi.quantity,' (',oi.item_status,')') END ORDER BY oi.item_id SEPARATOR ', '),'') AS items, " +
                "COALESCE(GROUP_CONCAT(CASE WHEN oi.item_id IS NULL THEN NULL ELSE CONCAT(COALESCE(NULLIF(m.image,''),'medicine.svg'),'::',COALESCE(m.name,'Medicine'),'::',oi.quantity,'::',COALESCE(oi.item_status,o.order_status),'::',oi.price,'::',COALESCE(DATE_FORMAT(oi.expected_delivery_at,'%Y-%m-%d %H:%i'),'')) END ORDER BY oi.item_id SEPARATOR '||'),'') AS item_details " +
                "FROM orders o JOIN users u ON o.user_id=u.user_id " +
                "LEFT JOIN order_items oi ON o.order_id=oi.order_id " +
                "LEFT JOIN medicines m ON oi.medicine_id=m.medicine_id ";
        if(!all) sql += "WHERE o.user_id=? ";
        sql += "GROUP BY o.order_id,u.name,o.total_amount,o.order_status,o.order_date,o.delivery_method ORDER BY o.order_date DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            if(!all) ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            while(rs.next()) {
                list.add(mapOrder(rs));
            }
        } catch(Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Map<String,Object>> getOrdersForPharmacist(int pharmacistId) {
        List<Map<String,Object>> list = new ArrayList<>();
        String sql = "SELECT o.order_id,u.name AS customer_name,SUM(oi.price * oi.quantity) AS total_amount,o.order_date,o.delivery_method, " +
                "CASE WHEN COUNT(DISTINCT oi.item_status)=1 THEN MAX(oi.item_status) ELSE 'Mixed' END AS order_status, " +
                "GROUP_CONCAT(CONCAT(m.name,' x ',oi.quantity,' (',oi.item_status,')') ORDER BY oi.item_id SEPARATOR ', ') AS items, " +
                "GROUP_CONCAT(CONCAT(COALESCE(NULLIF(m.image,''),'medicine.svg'),'::',m.name,'::',oi.quantity,'::',oi.item_status,'::',oi.price,'::',COALESCE(DATE_FORMAT(oi.expected_delivery_at,'%Y-%m-%d %H:%i'),'')) ORDER BY oi.item_id SEPARATOR '||') AS item_details, " +
                "MIN(oi.expected_delivery_at) AS expected_delivery_at " +
                "FROM orders o " +
                "JOIN users u ON o.user_id=u.user_id " +
                "JOIN order_items oi ON o.order_id=oi.order_id " +
                "JOIN medicines m ON oi.medicine_id=m.medicine_id " +
                "WHERE m.created_by=? " +
                "GROUP BY o.order_id,u.name,o.order_date,o.delivery_method ORDER BY o.order_date DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, pharmacistId);
            ResultSet rs = ps.executeQuery();
            while(rs.next()) {
                list.add(mapOrder(rs));
            }
        } catch(Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    private Map<String,Object> mapOrder(ResultSet rs) throws SQLException {
        Map<String,Object> row = new HashMap<>();
        row.put("orderId", rs.getInt("order_id"));
        row.put("customerName", rs.getString("customer_name"));
        row.put("totalAmount", rs.getDouble("total_amount"));
        row.put("orderStatus", rs.getString("order_status"));
        row.put("orderDate", rs.getString("order_date"));
        row.put("deliveryMethod", rs.getString("delivery_method"));
        row.put("items", rs.getString("items"));
        row.put("itemDetails", rs.getString("item_details"));
        try {
            row.put("expectedDeliveryAt", rs.getString("expected_delivery_at"));
        } catch (SQLException ignored) {
            row.put("expectedDeliveryAt", "");
        }
        return row;
    }

    public boolean updateOrderStatus(int orderId, String status, int pharmacistId) {
        return updateOrderStatus(orderId, status, pharmacistId, null);
    }

    public boolean updateOrderStatus(int orderId, String status, int pharmacistId, Timestamp expectedDeliveryAt) {
        if (!isAllowedStatus(status)) return false;
        if ("Approved".equals(status) && expectedDeliveryAt == null) return false;

        try (Connection con = DBConnection.getConnection()) {
            con.setAutoCommit(false);
            String sql = statusUpdateSql(status);
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setString(1, status);
                if ("Approved".equals(status)) {
                    ps.setTimestamp(2, expectedDeliveryAt);
                    ps.setInt(3, orderId);
                    ps.setInt(4, pharmacistId);
                } else if ("Completed".equals(status)) {
                    if (expectedDeliveryAt == null) ps.setNull(2, Types.TIMESTAMP);
                    else ps.setTimestamp(2, expectedDeliveryAt);
                    ps.setInt(3, orderId);
                    ps.setInt(4, pharmacistId);
                } else {
                    ps.setInt(2, orderId);
                    ps.setInt(3, pharmacistId);
                }
                if (ps.executeUpdate() == 0) {
                    con.rollback();
                    return false;
                }
            }

            syncOrderStatus(con, orderId);
            con.commit();
            return true;
        } catch(Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    private String statusUpdateSql(String status) {
        String base = "UPDATE order_items oi JOIN medicines m ON oi.medicine_id=m.medicine_id ";
        String where = " WHERE oi.order_id=? AND m.created_by=?";
        if ("Approved".equals(status)) {
            return base + "SET oi.item_status=?, oi.expected_delivery_at=?" + where;
        }
        if ("Completed".equals(status)) {
            return base + "SET oi.item_status=?, oi.expected_delivery_at=COALESCE(?, oi.expected_delivery_at)" + where;
        }
        return base + "SET oi.item_status=?, oi.expected_delivery_at=NULL" + where;
    }

    private boolean isAllowedStatus(String status) {
        return "Pending".equals(status) || "Approved".equals(status)
                || "Completed".equals(status) || "Cancelled".equals(status);
    }

    private void syncOrderStatus(Connection con, int orderId) throws SQLException {
        String status = "Pending";
        String sql = "SELECT COUNT(*) total, " +
                "SUM(CASE WHEN item_status='Pending' THEN 1 ELSE 0 END) pending_count, " +
                "SUM(CASE WHEN item_status='Completed' THEN 1 ELSE 0 END) completed_count, " +
                "SUM(CASE WHEN item_status='Cancelled' THEN 1 ELSE 0 END) cancelled_count " +
                "FROM order_items WHERE order_id=?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                int total = rs.getInt("total");
                int pending = rs.getInt("pending_count");
                int completed = rs.getInt("completed_count");
                int cancelled = rs.getInt("cancelled_count");

                if (total > 0 && completed == total) status = "Completed";
                else if (total > 0 && cancelled == total) status = "Cancelled";
                else if (pending == 0) status = "Approved";
            }
        }

        try (PreparedStatement ps = con.prepareStatement("UPDATE orders SET order_status=? WHERE order_id=?")) {
            ps.setString(1, status);
            ps.setInt(2, orderId);
            ps.executeUpdate();
        }
    }

    public Map<String,Object> analytics() {
        Map<String,Object> a = new HashMap<>();
        try (Connection con = DBConnection.getConnection();
             Statement st = con.createStatement()) {
            ResultSet rs = st.executeQuery("SELECT COUNT(*) c, COALESCE(SUM(total_amount),0) s FROM orders");
            if(rs.next()) {
                a.put("totalOrders", rs.getInt("c"));
                a.put("totalSales", rs.getDouble("s"));
            }

            rs = st.executeQuery("SELECT COUNT(*) c FROM orders WHERE order_status='Pending'");
            if(rs.next()) a.put("pendingOrders", rs.getInt("c"));

            rs = st.executeQuery("SELECT COUNT(*) c FROM medicines WHERE quantity <= 15");
            if(rs.next()) a.put("lowStock", rs.getInt("c"));

            rs = st.executeQuery("SELECT m.name, SUM(oi.quantity) q FROM order_items oi JOIN medicines m ON oi.medicine_id=m.medicine_id GROUP BY m.medicine_id,m.name ORDER BY q DESC LIMIT 1");
            if(rs.next()) {
                a.put("topMedicine", rs.getString("name"));
                a.put("topQty", rs.getInt("q"));
            } else {
                a.put("topMedicine", "No orders yet");
                a.put("topQty", 0);
            }
        } catch(Exception e) {
            e.printStackTrace();
        }
        return a;
    }

    public Map<String,Object> analytics(int pharmacistId) {
        Map<String,Object> a = new HashMap<>();
        try (Connection con = DBConnection.getConnection()) {
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT COUNT(DISTINCT o.order_id) c, COALESCE(SUM(oi.price * oi.quantity),0) s " +
                            "FROM order_items oi JOIN orders o ON oi.order_id=o.order_id JOIN medicines m ON oi.medicine_id=m.medicine_id " +
                            "WHERE m.created_by=?")) {
                ps.setInt(1, pharmacistId);
                ResultSet rs = ps.executeQuery();
                if(rs.next()) {
                    a.put("totalOrders", rs.getInt("c"));
                    a.put("totalSales", rs.getDouble("s"));
                }
            }

            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT COUNT(DISTINCT oi.order_id) c FROM order_items oi JOIN medicines m ON oi.medicine_id=m.medicine_id " +
                            "WHERE m.created_by=? AND oi.item_status='Pending'")) {
                ps.setInt(1, pharmacistId);
                ResultSet rs = ps.executeQuery();
                if(rs.next()) a.put("pendingOrders", rs.getInt("c"));
            }

            try (PreparedStatement ps = con.prepareStatement("SELECT COUNT(*) c FROM medicines WHERE created_by=? AND quantity <= 15")) {
                ps.setInt(1, pharmacistId);
                ResultSet rs = ps.executeQuery();
                if(rs.next()) a.put("lowStock", rs.getInt("c"));
            }

            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT m.name, SUM(oi.quantity) q FROM order_items oi JOIN medicines m ON oi.medicine_id=m.medicine_id " +
                            "WHERE m.created_by=? GROUP BY m.medicine_id,m.name ORDER BY q DESC LIMIT 1")) {
                ps.setInt(1, pharmacistId);
                ResultSet rs = ps.executeQuery();
                if(rs.next()) {
                    a.put("topMedicine", rs.getString("name"));
                    a.put("topQty", rs.getInt("q"));
                } else {
                    a.put("topMedicine", "No orders yet");
                    a.put("topQty", 0);
                }
            }
        } catch(Exception e) {
            e.printStackTrace();
        }
        return a;
    }
}
