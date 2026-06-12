package com.medicare.model;

public class Medicine {
    private int medicineId;
    private String name;
    private String category;
    private String description;
    private double price;
    private int quantity;
    private String expiryDate;
    private String image;
    private String deliveryMethods;
    private int createdBy;

    public int getMedicineId() { return medicineId; }
    public void setMedicineId(int medicineId) { this.medicineId = medicineId; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public double getPrice() { return price; }
    public void setPrice(double price) { this.price = price; }

    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }

    public String getExpiryDate() { return expiryDate; }
    public void setExpiryDate(String expiryDate) { this.expiryDate = expiryDate; }

    public String getImage() { return image; }
    public void setImage(String image) { this.image = image; }

    public String getDeliveryMethods() { return deliveryMethods; }
    public void setDeliveryMethods(String deliveryMethods) { this.deliveryMethods = deliveryMethods; }

    public int getCreatedBy() { return createdBy; }
    public void setCreatedBy(int createdBy) { this.createdBy = createdBy; }
}
