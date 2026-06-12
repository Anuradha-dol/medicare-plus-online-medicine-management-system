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
