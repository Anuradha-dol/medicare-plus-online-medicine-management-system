<%@ page import="com.medicare.dao.MedicineDAO,com.medicare.dao.CartOrderDAO,com.medicare.model.Medicine,java.util.*" %>
<%@ include file="../WEB-INF/auth.jsp" %>
<% if(!"user".equals(authUser.getRole())) { response.sendRedirect(authHome); return; } %>
<%
MedicineDAO medicineDAO = new MedicineDAO();
CartOrderDAO orderDAO = new CartOrderDAO();
List<Medicine> medicines = medicineDAO.getAvailable("");
List<Map<String,Object>> cart = orderDAO.getCart(authUser.getUserId());
List<Map<String,Object>> orders = orderDAO.getOrders(authUser.getUserId(), false);

int cartItems = 0;
double cartTotal = 0;
for(Map<String,Object> item: cart) {
    cartItems += (int)item.get("quantity");
    cartTotal += (double)item.get("subtotal");
}

int pendingOrders = 0;
int completedOrders = 0;
for(Map<String,Object> order: orders) {
    String status = String.valueOf(order.get("orderStatus"));
    if("Pending".equals(status) || "Approved".equals(status)) pendingOrders++;
    if("Completed".equals(status)) completedOrders++;
}

int maxStock = 1;
for(Medicine medicine: medicines) if(medicine.getQuantity() > maxStock) maxStock = medicine.getQuantity();
%>
<%@ include file="../WEB-INF/header.jsp" %>

<section class="dashboard-hero user-hero">
    <div>
        <span class="eyebrow">Customer Dashboard</span>
        <h1>Find medicines and track your orders</h1>
        <p>Browse approved pharmacist stock, manage your cart, and follow every order from one clean dashboard.</p>
    </div>
    <div class="hero-metric">
        <small>Cart Total</small>
        <strong>Rs. <%=String.format("%.2f", cartTotal)%></strong>
        <span><%=cartItems%> items ready</span>
    </div>
</section>

<section class="metric-grid">
    <div class="metric-card green-card"><span>Available Medicines</span><strong><%=medicines.size()%></strong><small>Ready to order</small></div>
    <div class="metric-card blue-card"><span>Cart Items</span><strong><%=cartItems%></strong><small>Across <%=cart.size()%> medicines</small></div>
    <div class="metric-card orange-card"><span>Active Orders</span><strong><%=pendingOrders%></strong><small>Pending or approved</small></div>
    <div class="metric-card violet-card"><span>Completed</span><strong><%=completedOrders%></strong><small>Delivered order history</small></div>
</section>

<section class="dashboard-grid">
    <div class="analytics-panel wide">
        <div class="panel-title">
            <h2>Popular Stock Snapshot</h2>
            <a class="btn ghost" href="medicines.jsp">Browse All</a>
        </div>
        <div class="bar-chart">
            <% int shown = 0; for(Medicine medicine: medicines) { if(shown++ >= 5) break; %>
            <div class="chart-row">
                <span><%=medicine.getName()%></span>
                <div><i style="width:<%=medicine.getQuantity()*100/maxStock%>%"></i></div>
                <strong><%=medicine.getQuantity()%></strong>
            </div>
            <% } %>
            <% if(medicines.isEmpty()) { %><p class="center-copy">No available medicines right now.</p><% } %>
        </div>
    </div>

    <div class="analytics-panel">
        <div class="panel-title"><h2>Order Progress</h2></div>
        <div class="donut-card" style="--value:<%=orders.isEmpty()?0:(completedOrders*100/orders.size())%>%">
            <span><%=orders.isEmpty()?0:(completedOrders*100/orders.size())%>%</span>
        </div>
        <p class="center-copy">Completed from your total order history.</p>
    </div>
</section>

<section class="quick-actions">
    <a class="action-tile green-card" href="medicines.jsp"><strong>Browse Medicines</strong><span>Search approved pharmacy stock</span></a>
    <a class="action-tile blue-card" href="cart.jsp"><strong>My Cart</strong><span>Review quantities and checkout</span></a>
    <a class="action-tile violet-card" href="orders.jsp"><strong>My Orders</strong><span>Track order status and items</span></a>
</section>

<%@ include file="../WEB-INF/footer.jsp" %>
