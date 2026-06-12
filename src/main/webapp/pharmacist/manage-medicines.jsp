<%@ page import="com.medicare.dao.MedicineDAO,com.medicare.model.Medicine,java.util.*" %>
<%@ include file="../WEB-INF/auth.jsp" %>
<% if(!"pharmacist".equals(authUser.getRole())) { response.sendRedirect(authHome); return; } %>
<%
MedicineDAO dao = new MedicineDAO();
Medicine editMedicine = (Medicine) request.getAttribute("editMedicine");
List<Medicine> medicines = dao.getByOwner(authUser.getUserId());
String selectedDeliveryMethods = editMedicine != null && editMedicine.getDeliveryMethods() != null
        ? editMedicine.getDeliveryMethods()
        : MedicineDAO.DEFAULT_DELIVERY_METHODS;
%>
<%@ include file="../WEB-INF/header.jsp" %>
<div class="card">
    <h2><%= editMedicine == null ? "Manage Medicines" : "Edit Medicine" %></h2>
    <form action="medicines" method="post" enctype="multipart/form-data">
        <input type="hidden" name="action" value="<%= editMedicine == null ? "add" : "update" %>">
        <% if(editMedicine != null) { %>
            <input type="hidden" name="medicineId" value="<%=editMedicine.getMedicineId()%>">
        <% } %>
        <label>Medicine Name</label>
        <input name="name" value="<%= editMedicine != null ? editMedicine.getName() : "" %>" required>
        <label>Category</label>
        <input name="category" value="<%= editMedicine != null ? editMedicine.getCategory() : "" %>" required>
        <label>Description</label>
        <textarea name="description"><%= editMedicine != null ? editMedicine.getDescription() : "" %></textarea>
        <label>Price</label>
        <input type="number" step="0.01" min="0" name="price" value="<%= editMedicine != null ? editMedicine.getPrice() : "" %>" required>
        <label>Quantity</label>
        <input type="number" min="0" name="quantity" value="<%= editMedicine != null ? editMedicine.getQuantity() : "" %>" required>
        <label>Expiry Date</label>
        <input type="date" name="expiryDate" value="<%= editMedicine != null ? editMedicine.getExpiryDate() : "" %>">
        <label>Medicine Image</label>
        <% if(editMedicine != null && editMedicine.getImage() != null) { %>
            <div class="image-preview-row">
                <img src="../assets/images/<%=editMedicine.getImage()%>" alt="<%=editMedicine.getName()%>">
                <span>Current image. Upload a new file only if you want to replace it.</span>
            </div>
        <% } %>
        <input type="file" name="image" accept="image/*">
        <div class="delivery-config">
            <label>Available Medicine Transport Methods</label>
            <p class="muted">Select the delivery services this medicine can use. Customers can only choose methods enabled here.</p>
            <div class="delivery-check-grid">
                <label>
                    <input type="checkbox" name="deliveryMethods" value="<%=MedicineDAO.STANDARD_MEDICAL_COURIER%>" <%= selectedDeliveryMethods.contains(MedicineDAO.STANDARD_MEDICAL_COURIER) ? "checked" : "" %>>
                    <span><%=MedicineDAO.STANDARD_MEDICAL_COURIER%></span>
                </label>
                <label>
                    <input type="checkbox" name="deliveryMethods" value="<%=MedicineDAO.EXPRESS_MEDICAL_COURIER%>" <%= selectedDeliveryMethods.contains(MedicineDAO.EXPRESS_MEDICAL_COURIER) ? "checked" : "" %>>
                    <span><%=MedicineDAO.EXPRESS_MEDICAL_COURIER%></span>
                </label>
                <label>
                    <input type="checkbox" name="deliveryMethods" value="<%=MedicineDAO.MEDICARE_DELIVERY_SERVICE%>" <%= selectedDeliveryMethods.contains(MedicineDAO.MEDICARE_DELIVERY_SERVICE) ? "checked" : "" %>>
                    <span><%=MedicineDAO.MEDICARE_DELIVERY_SERVICE%></span>
                </label>
            </div>
        </div>
        <button type="submit"><%= editMedicine == null ? "Add Medicine" : "Update Medicine" %></button>
        <% if(editMedicine != null) { %>
            <a class="btn" href="manage-medicines.jsp">Cancel Edit</a>
        <% } %>
        <a class="btn" href="dashboard.jsp">Back</a>
    </form>

    <table>
        <tr><th>Image</th><th>Name</th><th>Category</th><th>Price</th><th>Stock</th><th>Expiry</th><th>Transport</th><th>Action</th></tr>
        <% for(Medicine m: medicines) { %>
        <tr>
            <td><img class="table-image" src="../assets/images/<%=m.getImage()%>" alt="<%=m.getName()%>"></td>
            <td><%=m.getName()%></td>
            <td><%=m.getCategory()%></td>
            <td>Rs. <%=m.getPrice()%></td>
            <td><span class="badge <%=m.getQuantity()<=15?"low":""%>"><%=m.getQuantity()%></span></td>
            <td><%=m.getExpiryDate()%></td>
            <td><span class="delivery-tags"><%=m.getDeliveryMethods()%></span></td>
            <td>
                <a class="btn" href="medicines?action=edit&id=<%=m.getMedicineId()%>">Edit</a>
                <a class="btn danger" onclick="return confirmDelete()" href="medicines?action=delete&id=<%=m.getMedicineId()%>">Delete</a>
