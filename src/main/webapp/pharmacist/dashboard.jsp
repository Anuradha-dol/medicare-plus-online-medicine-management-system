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
    <div class="metric-card blue-card"><span>Total Stock</span><strong><%=totalStock%></strong><small>Units available</small></div>
    <div class="metric-card orange-card"><span>Pending Orders</span><strong><%=pendingOrders%></strong><small>Need pharmacist action</small></div>
    <div class="metric-card violet-card"><span>Low Stock</span><strong><%=lowStock.size()%></strong><small>Restock recommended</small></div>
</section>

<section class="dashboard-grid">
    <div class="analytics-panel">
        <div class="panel-title"><h2>Stock Health</h2></div>
        <div class="donut-card" style="--value:<%=stockHealth%>%">
            <span><%=stockHealth%>%</span>
        </div>
        <p class="center-copy">Higher score means fewer low-stock medicines.</p>
    </div>

    <div class="analytics-panel wide">
        <div class="panel-title">
            <h2>Latest Orders</h2>
            <a class="btn ghost" href="orders.jsp">Manage Orders</a>
        </div>
        <table class="compact-table">
            <tr><th>Order</th><th>Customer</th><th>Your Total</th><th>Status</th></tr>
            <% int shown = 0; for(Map<String,Object> order: orders) { if(shown++ >= 5) break; %>
            <tr>
                <td>#<%=order.get("orderId")%></td>
                <td><%=order.get("customerName")%></td>
                <td>Rs. <%=order.get("totalAmount")%></td>
                <td><span class="badge"><%=order.get("orderStatus")%></span></td>
            </tr>
            <% } %>
            <% if(orders.isEmpty()) { %><tr><td colspan="4">No orders for your medicines yet.</td></tr><% } %>
        </table>
    </div>
</section>

<section class="quick-actions">
    <a class="action-tile green-card" href="manage-medicines.jsp"><strong>Manage Medicines</strong><span>Add, edit, and remove your stock</span></a>
    <a class="action-tile blue-card" href="orders.jsp"><strong>Manage Orders</strong><span>Update customer order status</span></a>
    <a class="action-tile violet-card" href="analytics.jsp"><strong>Analytics</strong><span>Review stock and sales performance</span></a>
    <a class="action-tile orange-card" href="manage-medicines.jsp"><strong>Low Stock</strong><span><%=lowStock.size()%> items need attention</span></a>
</section>

<%@ include file="../WEB-INF/footer.jsp" %>
