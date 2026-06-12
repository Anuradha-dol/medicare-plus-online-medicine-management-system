<%@ page import="com.medicare.dao.MedicineDAO,com.medicare.dao.CartOrderDAO,com.medicare.model.Medicine,java.util.*" %>
<%@ include file="../WEB-INF/auth.jsp" %>
<% if(!"pharmacist".equals(authUser.getRole())) { response.sendRedirect(authHome); return; } %>
<%
MedicineDAO medicineDAO = new MedicineDAO();
CartOrderDAO orderDAO = new CartOrderDAO();
List<Medicine> medicines = medicineDAO.getByOwner(authUser.getUserId());
List<Medicine> lowStock = medicineDAO.lowStock(authUser.getUserId());
List<Map<String,Object>> orders = orderDAO.getOrdersForPharmacist(authUser.getUserId());
Map<String,Object> analytics = orderDAO.analytics(authUser.getUserId());

int totalStock = 0;
for(Medicine medicine: medicines) totalStock += medicine.getQuantity();

int pendingOrders = 0;
int completedOrders = 0;
for(Map<String,Object> order: orders) {
    String status = String.valueOf(order.get("orderStatus"));
    if("Pending".equals(status) || "Mixed".equals(status)) pendingOrders++;
    if("Completed".equals(status)) completedOrders++;
