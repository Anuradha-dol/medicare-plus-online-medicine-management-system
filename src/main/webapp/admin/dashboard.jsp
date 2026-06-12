<%@ page import="com.medicare.dao.UserDAO,com.medicare.dao.MedicineDAO,com.medicare.dao.CartOrderDAO,com.medicare.dao.OrderIssueDAO,com.medicare.model.User,com.medicare.model.Medicine,java.util.*" %>
<%@ include file="../WEB-INF/auth.jsp" %>
<% if(!"admin".equals(authUser.getRole())) { response.sendRedirect(authHome); return; } %>
<%
UserDAO userDAO = new UserDAO();
MedicineDAO medicineDAO = new MedicineDAO();
CartOrderDAO orderDAO = new CartOrderDAO();
OrderIssueDAO issueDAO = new OrderIssueDAO();

List<User> users = userDAO.getByRole("user");
List<User> pharmacists = userDAO.getByRole("pharmacist");
List<Medicine> medicines = medicineDAO.getAll("");
List<Medicine> lowStock = medicineDAO.lowStock();
List<Map<String,Object>> orders = orderDAO.getOrders(0, true);
Map<String,Object> analytics = orderDAO.analytics();
Map<String,Object> issueAnalytics = issueDAO.analytics();

int pendingPharmacists = 0;
int approvedPharmacists = 0;
for(User pharmacist: pharmacists) {
    if("pending".equals(pharmacist.getApprovalStatus())) pendingPharmacists++;
    if("approved".equals(pharmacist.getApprovalStatus())) approvedPharmacists++;
}

int pendingOrders = 0;
int approvedOrders = 0;
int completedOrders = 0;
int cancelledOrders = 0;
for(Map<String,Object> order: orders) {
    String status = String.valueOf(order.get("orderStatus"));
    if("Pending".equals(status)) pendingOrders++;
    if("Approved".equals(status)) approvedOrders++;
    if("Completed".equals(status)) completedOrders++;
    if("Cancelled".equals(status)) cancelledOrders++;
}

int totalPeople = Math.max(1, users.size() + pharmacists.size() + 1);
int maxOrderStatus = Math.max(1, Math.max(Math.max(pendingOrders, approvedOrders), Math.max(completedOrders, cancelledOrders)));
double totalSales = analytics.get("totalSales") == null ? 0 : ((Number)analytics.get("totalSales")).doubleValue();
int activeIssues = issueAnalytics.get("activeIssues") == null ? 0 : ((Number)issueAnalytics.get("activeIssues")).intValue();
%>
<%@ include file="../WEB-INF/header.jsp" %>

<section class="dashboard-hero admin-hero">
    <div>
        <span class="eyebrow">Admin Command Center</span>
        <h1>System analytics and account control</h1>
        <p>Monitor platform health, approve pharmacists, inspect orders, and keep medicine availability moving.</p>
    </div>
    <div class="hero-metric">
        <small>Total Sales</small>
        <strong>Rs. <%=String.format("%.2f", totalSales)%></strong>
        <span><%=orders.size()%> orders tracked</span>
    </div>
</section>

<section class="metric-grid">
    <div class="metric-card green-card"><span>Users</span><strong><%=users.size()%></strong><small>Registered customers</small></div>
    <div class="metric-card blue-card"><span>Pharmacists</span><strong><%=pharmacists.size()%></strong><small><%=approvedPharmacists%> approved, <%=pendingPharmacists%> pending</small></div>
    <div class="metric-card violet-card"><span>Medicines</span><strong><%=medicines.size()%></strong><small><%=lowStock.size()%> low stock alerts</small></div>
    <div class="metric-card orange-card"><span>Messages</span><strong><%=activeIssues%></strong><small>Open customer order messages</small></div>
</section>

<section class="dashboard-grid">
    <div class="analytics-panel wide">
        <div class="panel-title">
            <h2>Platform Distribution</h2>
            <a class="btn ghost" href="manage-pharmacists.jsp">Review Approvals</a>
        </div>
        <div class="bar-chart">
            <div class="chart-row"><span>Customers</span><div><i style="width:<%=users.size()*100/totalPeople%>%"></i></div><strong><%=users.size()%></strong></div>
            <div class="chart-row"><span>Pharmacists</span><div><i class="blue-bar" style="width:<%=pharmacists.size()*100/totalPeople%>%"></i></div><strong><%=pharmacists.size()%></strong></div>
            <div class="chart-row"><span>Admins</span><div><i class="violet-bar" style="width:<%=100/totalPeople%>%"></i></div><strong>1</strong></div>
        </div>
    </div>

    <div class="analytics-panel">
        <div class="panel-title"><h2>Approval Queue</h2></div>
        <div class="donut-card" style="--value:<%=pharmacists.isEmpty()?0:(pendingPharmacists*100/pharmacists.size())%>%">
            <span><%=pendingPharmacists%></span>
        </div>
        <p class="center-copy">Pending pharmacist accounts need admin approval before login.</p>
    </div>
</section>

<section class="dashboard-grid">
    <div class="analytics-panel">
        <div class="panel-title"><h2>Order Status</h2></div>
        <div class="bar-chart compact">
            <div class="chart-row"><span>Pending</span><div><i style="width:<%=pendingOrders*100/maxOrderStatus%>%"></i></div><strong><%=pendingOrders%></strong></div>
            <div class="chart-row"><span>Approved</span><div><i class="blue-bar" style="width:<%=approvedOrders*100/maxOrderStatus%>%"></i></div><strong><%=approvedOrders%></strong></div>
            <div class="chart-row"><span>Completed</span><div><i class="green-bar" style="width:<%=completedOrders*100/maxOrderStatus%>%"></i></div><strong><%=completedOrders%></strong></div>
            <div class="chart-row"><span>Cancelled</span><div><i class="red-bar" style="width:<%=cancelledOrders*100/maxOrderStatus%>%"></i></div><strong><%=cancelledOrders%></strong></div>
        </div>
    </div>

    <div class="analytics-panel wide">
        <div class="panel-title">
            <h2>Recent Orders</h2>
            <a class="btn ghost" href="orders.jsp">View All</a>
        </div>
        <table class="compact-table">
            <tr><th>Order</th><th>Customer</th><th>Total</th><th>Status</th></tr>
            <% int shown = 0; for(Map<String,Object> order: orders) { if(shown++ >= 5) break; %>
            <tr>
                <td>#<%=order.get("orderId")%></td>
                <td><%=order.get("customerName")%></td>
                <td>Rs. <%=order.get("totalAmount")%></td>
                <td><span class="badge"><%=order.get("orderStatus")%></span></td>
            </tr>
            <% } %>
            <% if(orders.isEmpty()) { %><tr><td colspan="4">No orders yet.</td></tr><% } %>
        </table>
    </div>
</section>

<section class="quick-actions">
    <a class="action-tile green-card" href="manage-users.jsp"><strong>Manage Users</strong><span>View and delete customer accounts</span></a>
    <a class="action-tile blue-card" href="manage-pharmacists.jsp"><strong>Manage Pharmacists</strong><span>Approve or remove pharmacist accounts</span></a>
    <a class="action-tile violet-card" href="orders.jsp"><strong>View Orders</strong><span>Monitor all customer orders</span></a>
    <a class="action-tile orange-card" href="order-messages.jsp"><strong>Order Messages</strong><span>Respond to customer delivery issues</span></a>
</section>

<%@ include file="../WEB-INF/footer.jsp" %>
