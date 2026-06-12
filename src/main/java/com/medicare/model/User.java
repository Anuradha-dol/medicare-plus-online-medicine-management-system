package com.medicare.model;

public class User {
    private int userId;
    private String name;
    private String email;
    private String password;
    private String phone;
    private String address;
    private String role;
    private String pharmacyName;
    private String pharmacyAddress;
    private String approvalStatus;

    public User() {}

    public User(int userId, String name, String email, String phone, String address, String role) {
        this.userId = userId;
        this.name = name;
        this.email = email;
        this.phone = phone;
        this.address = address;
        this.role = role;
        this.approvalStatus = "approved";
    }

    public User(int userId, String name, String email, String phone, String address, String role,
                String pharmacyName, String pharmacyAddress, String approvalStatus) {
        this.userId = userId;
        this.name = name;
        this.email = email;
        this.phone = phone;
        this.address = address;
        this.role = role;
        this.pharmacyName = pharmacyName;
        this.pharmacyAddress = pharmacyAddress;
        this.approvalStatus = approvalStatus;
    }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public String getPharmacyName() { return pharmacyName; }
    public void setPharmacyName(String pharmacyName) { this.pharmacyName = pharmacyName; }

    public String getPharmacyAddress() { return pharmacyAddress; }
    public void setPharmacyAddress(String pharmacyAddress) { this.pharmacyAddress = pharmacyAddress; }

    public String getApprovalStatus() { return approvalStatus; }
    public void setApprovalStatus(String approvalStatus) { this.approvalStatus = approvalStatus; }

    public boolean isApproved() {
        return "approved".equalsIgnoreCase(approvalStatus);
    }
}
