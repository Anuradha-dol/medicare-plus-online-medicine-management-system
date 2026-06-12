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
}

double sales = analytics.get("totalSales") == null ? 0 : ((Number)analytics.get("totalSales")).doubleValue();
int stockHealth = medicines.isEmpty() ? 0 : Math.max(0, 100 - (lowStock.size() * 100 / medicines.size()));
%>
<%@ include file="../WEB-INF/header.jsp" %>

<section class="dashboard-hero pharmacist-hero">
    <div>
        <span class="eyebrow">Pharmacist Workspace</span>
        <h1>Manage stock, sales, and customer orders</h1>
        <p>Your approved pharmacy dashboard for medicine inventory, low-stock control, and order fulfilment.</p>
    </div>
    <div class="hero-metric">
        <small>My Sales</small>
        <strong>Rs. <%=String.format("%.2f", sales)%></strong>
        <span><%=orders.size()%> received orders</span>
    </div>
</section>

<section class="metric-grid">
    <div class="metric-card green-card"><span>My Medicines</span><strong><%=medicines.size()%></strong><small>Active inventory items</small></div>
