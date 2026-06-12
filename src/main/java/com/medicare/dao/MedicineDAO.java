package com.medicare.dao;

import com.medicare.config.DBConnection;
import com.medicare.model.Medicine;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class MedicineDAO {
    public static final String STANDARD_MEDICAL_COURIER = "Standard Medical Courier";
    public static final String EXPRESS_MEDICAL_COURIER = "Express Medical Courier";
    public static final String MEDICARE_DELIVERY_SERVICE = "MediCare Delivery Service";
    public static final String DEFAULT_DELIVERY_METHODS = STANDARD_MEDICAL_COURIER + "," + MEDICARE_DELIVERY_SERVICE;
    private static volatile boolean schemaChecked = false;

    public MedicineDAO() {
        ensureMedicineSchema();
    }

    private static synchronized void ensureMedicineSchema() {
        if (schemaChecked) return;

        try (Connection con = DBConnection.getConnection();
             Statement st = con.createStatement();
             ResultSet rs = con.getMetaData().getColumns(con.getCatalog(), null, "medicines", "delivery_methods")) {
            if (!rs.next()) {
                st.executeUpdate("ALTER TABLE medicines ADD COLUMN delivery_methods VARCHAR(180) NOT NULL DEFAULT '" + DEFAULT_DELIVERY_METHODS + "' AFTER image");
            }
            schemaChecked = true;
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private Medicine map(ResultSet rs) throws Exception {
        Medicine m = new Medicine();
        m.setMedicineId(rs.getInt("medicine_id"));
        m.setName(rs.getString("name"));
        m.setCategory(rs.getString("category"));
        m.setDescription(rs.getString("description"));
        m.setPrice(rs.getDouble("price"));
        m.setQuantity(rs.getInt("quantity"));
        m.setExpiryDate(rs.getString("expiry_date"));
        m.setImage(rs.getString("image"));
        m.setDeliveryMethods(rs.getString("delivery_methods"));
        m.setCreatedBy(rs.getInt("created_by"));
        return m;
    }

    public List<Medicine> getAll(String search) {
        List<Medicine> list = new ArrayList<>();
        String sql = "SELECT * FROM medicines WHERE name LIKE ? OR category LIKE ? ORDER BY medicine_id DESC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            String key = "%" + (search == null ? "" : search) + "%";
            ps.setString(1, key);
            ps.setString(2, key);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(map(rs));
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public Medicine getById(int id) {
        String sql = "SELECT * FROM medicines WHERE medicine_id=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return map(rs);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public Medicine getByIdForOwner(int id, int ownerId) {
        String sql = "SELECT * FROM medicines WHERE medicine_id=? AND created_by=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, id);
            ps.setInt(2, ownerId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return map(rs);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<Medicine> getByOwner(int ownerId) {
        List<Medicine> list = new ArrayList<>();
        String sql = "SELECT * FROM medicines WHERE created_by=? ORDER BY medicine_id DESC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, ownerId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(map(rs));
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Medicine> getAvailable(String search) {
        List<Medicine> list = new ArrayList<>();
        String sql = "SELECT m.* FROM medicines m JOIN users u ON m.created_by=u.user_id " +
                "WHERE m.quantity > 0 AND u.role='pharmacist' AND u.approval_status='approved' " +
                "AND (m.name LIKE ? OR m.category LIKE ?) ORDER BY m.medicine_id DESC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            String key = "%" + (search == null ? "" : search) + "%";
            ps.setString(1, key);
            ps.setString(2, key);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(map(rs));
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean add(Medicine m, int createdBy) {
        String sql = "INSERT INTO medicines(name,category,description,price,quantity,expiry_date,image,delivery_methods,created_by) VALUES(?,?,?,?,?,?,?,?,?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, m.getName());
            ps.setString(2, m.getCategory());
            ps.setString(3, m.getDescription());
            ps.setDouble(4, m.getPrice());
            ps.setInt(5, m.getQuantity());
            ps.setString(6, m.getExpiryDate());
            ps.setString(7, safeImage(m.getImage()));
            ps.setString(8, safeDeliveryMethods(m.getDeliveryMethods()));
            ps.setInt(9, createdBy);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean update(Medicine m) {
        String sql = "UPDATE medicines SET name=?, category=?, description=?, price=?, quantity=?, expiry_date=?, delivery_methods=? WHERE medicine_id=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, m.getName());
            ps.setString(2, m.getCategory());
            ps.setString(3, m.getDescription());
            ps.setDouble(4, m.getPrice());
            ps.setInt(5, m.getQuantity());
            ps.setString(6, m.getExpiryDate());
            ps.setString(7, safeDeliveryMethods(m.getDeliveryMethods()));
            ps.setInt(8, m.getMedicineId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean update(Medicine m, int ownerId) {
        String sql = "UPDATE medicines SET name=?, category=?, description=?, price=?, quantity=?, expiry_date=?, image=COALESCE(?, image), delivery_methods=? WHERE medicine_id=? AND created_by=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, m.getName());
            ps.setString(2, m.getCategory());
            ps.setString(3, m.getDescription());
            ps.setDouble(4, m.getPrice());
            ps.setInt(5, m.getQuantity());
            ps.setString(6, m.getExpiryDate());
            ps.setString(7, isBlank(m.getImage()) ? null : m.getImage());
            ps.setString(8, safeDeliveryMethods(m.getDeliveryMethods()));
            ps.setInt(9, m.getMedicineId());
            ps.setInt(10, ownerId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean delete(int id, int ownerId) {
        String sql = "DELETE FROM medicines WHERE medicine_id=? AND created_by=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, id);
            ps.setInt(2, ownerId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<Medicine> lowStock() {
        List<Medicine> list = new ArrayList<>();
        String sql = "SELECT * FROM medicines WHERE quantity <= 15 ORDER BY quantity ASC";
        try (Connection con = DBConnection.getConnection();
             Statement st = con.createStatement()) {
            ResultSet rs = st.executeQuery(sql);
            while (rs.next()) list.add(map(rs));
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Medicine> lowStock(int ownerId) {
        List<Medicine> list = new ArrayList<>();
        String sql = "SELECT * FROM medicines WHERE created_by=? AND quantity <= 15 ORDER BY quantity ASC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, ownerId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(map(rs));
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    private String safeImage(String image) {
        return isBlank(image) ? "medicine.svg" : image;
    }

    private String safeDeliveryMethods(String deliveryMethods) {
        return isBlank(deliveryMethods) ? DEFAULT_DELIVERY_METHODS : deliveryMethods;
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }
}
