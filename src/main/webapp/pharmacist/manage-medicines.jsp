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
