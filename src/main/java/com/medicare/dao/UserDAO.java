package com.medicare.dao;

import com.medicare.config.DBConnection;
import com.medicare.config.PasswordUtil;
import com.medicare.model.User;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class UserDAO {
    private static volatile boolean schemaChecked = false;

    public UserDAO() {
        ensureUserSchema();
    }

    private static synchronized void ensureUserSchema() {
        if (schemaChecked) return;

        try (Connection con = DBConnection.getConnection();
             Statement st = con.createStatement()) {
            addColumnIfMissing(con, st, "pharmacy_name", "ALTER TABLE users ADD COLUMN pharmacy_name VARCHAR(150) NULL AFTER address");
            addColumnIfMissing(con, st, "pharmacy_address", "ALTER TABLE users ADD COLUMN pharmacy_address TEXT NULL AFTER pharmacy_name");
            addColumnIfMissing(con, st, "approval_status", "ALTER TABLE users ADD COLUMN approval_status ENUM('pending','approved') NOT NULL DEFAULT 'approved' AFTER role");

            st.executeUpdate("UPDATE users SET approval_status='approved' WHERE role <> 'pharmacist'");
            schemaChecked = true;
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private static void addColumnIfMissing(Connection con, Statement st, String columnName, String alterSql) throws SQLException {
        try (ResultSet rs = con.getMetaData().getColumns(con.getCatalog(), null, "users", columnName)) {
            if (!rs.next()) {
                st.executeUpdate(alterSql);
            }
        }
    }

    private User mapUser(ResultSet rs) throws SQLException {
        return new User(
                rs.getInt("user_id"),
                rs.getString("name"),
                rs.getString("email"),
                rs.getString("phone"),
                rs.getString("address"),
                rs.getString("role"),
                rs.getString("pharmacy_name"),
                rs.getString("pharmacy_address"),
                rs.getString("approval_status")
        );
    }

    public User login(String email, String password) {
        String sql = "SELECT * FROM users WHERE email=? AND password=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, email);
            ps.setString(2, PasswordUtil.hash(password));
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return mapUser(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean register(User user) {
        String role = "pharmacist".equalsIgnoreCase(user.getRole()) ? "pharmacist" : "user";
        String approvalStatus = "pharmacist".equals(role) ? "pending" : "approved";

        String sql = "INSERT INTO users(name,email,password,phone,address,role,pharmacy_name,pharmacy_address,approval_status) VALUES(?,?,?,?,?,?,?,?,?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, user.getName());
            ps.setString(2, user.getEmail());
            ps.setString(3, PasswordUtil.hash(user.getPassword()));
            ps.setString(4, user.getPhone());
            ps.setString(5, user.getAddress());
            ps.setString(6, role);
            ps.setString(7, "pharmacist".equals(role) ? user.getPharmacyName() : null);
            ps.setString(8, "pharmacist".equals(role) ? user.getPharmacyAddress() : null);
            ps.setString(9, approvalStatus);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<User> getByRole(String role) {
        List<User> list = new ArrayList<>();
        String sql = "SELECT * FROM users WHERE role=? ORDER BY user_id DESC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, role);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapUser(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public User getById(int id) {
        String sql = "SELECT * FROM users WHERE user_id=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return mapUser(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean approvePharmacist(int id) {
        String sql = "UPDATE users SET approval_status='approved' WHERE user_id=? AND role='pharmacist'";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean deleteByRole(int id, String role) {
        String sql = "DELETE FROM users WHERE user_id=? AND role=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, id);
            ps.setString(2, role);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}
