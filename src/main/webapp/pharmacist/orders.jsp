<%@ page import="com.medicare.dao.CartOrderDAO,java.util.*" %>
<%!
private String dateTimeInputValue(Object value) {
    if (value == null) return "";
    String text = String.valueOf(value);
    if (text.trim().isEmpty() || "null".equals(text)) return "";
    text = text.replace('T', ' ');
    return text.length() >= 16 ? text.substring(0, 16).replace(' ', 'T') : text;
}
%>
<%@ include file="../WEB-INF/auth.jsp" %>
<% if(!"pharmacist".equals(authUser.getRole())) { response.sendRedirect(authHome); return; } %>
<%
List<Map<String,Object>> orders = new CartOrderDAO().getOrdersForPharmacist(authUser.getUserId());
%>
<%@ include file="../WEB-INF/header.jsp" %>
<div class="card order-page-head">
    <div>
        <span class="auth-kicker">Fulfillment</span>
        <h2>Manage Customer Orders</h2>
        <p class="muted">Each card shows the received date/time, transport method, ordered medicines, and your current fulfillment status.</p>
    </div>
    <a class="btn" href="dashboard.jsp">Back</a>
</div>
<% if(orders.isEmpty()) { %>
    <div class="card"><p>No orders found for your medicines.</p></div>
<% } else { %>
    <div class="order-card-list">
        <% for(Map<String,Object> o: orders) { String currentStatus = String.valueOf(o.get("orderStatus")); String statusClass = currentStatus.toLowerCase(Locale.ROOT); %>
        <% String expectedInput = dateTimeInputValue(o.get("expectedDeliveryAt")); %>
        <article class="order-card">
            <div class="order-card-head">
                <div>
                    <span class="auth-kicker">Customer Order</span>
                    <h3>Order #<%=o.get("orderId")%></h3>
                    <p><%=o.get("customerName")%></p>
                </div>
                <span class="badge status-<%=statusClass%>"><%=currentStatus%></span>
            </div>

            <div class="order-meta-grid">
                <div><small>Received Date & Time</small><strong><%=o.get("orderDate")%></strong></div>
