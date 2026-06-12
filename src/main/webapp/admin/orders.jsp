<%@ page import="com.medicare.dao.CartOrderDAO,java.util.*" %>
<%@ include file="../WEB-INF/auth.jsp" %>
<% if(!"admin".equals(authUser.getRole())) { response.sendRedirect(authHome); return; } %>
<%
List<Map<String,Object>> orders = new CartOrderDAO().getOrders(0, true);
%>
<%@ include file="../WEB-INF/header.jsp" %>
<div class="card order-page-head">
    <div>
        <span class="auth-kicker">Admin Review</span>
        <h2>All Customer Orders</h2>
        <p class="muted">View customer receipts with order time, delivery method, medicine images, total, and current status.</p>
    </div>
    <a class="btn" href="dashboard.jsp">Back</a>
</div>
<% if(orders.isEmpty()) { %>
    <div class="card"><p>No orders found.</p></div>
<% } else { %>
    <div class="order-card-list">
        <% for(Map<String,Object> o: orders) { String status = String.valueOf(o.get("orderStatus")); String statusClass = status.toLowerCase(Locale.ROOT); %>
        <article class="order-card">
            <div class="order-card-head">
                <div>
                    <span class="auth-kicker">Receipt</span>
                    <h3>Order #<%=o.get("orderId")%></h3>
                    <p><%=o.get("customerName")%></p>
                </div>
                <span class="badge status-<%=statusClass%>"><%=status%></span>
            </div>

            <div class="order-meta-grid">
                <div><small>Received Date & Time</small><strong><%=o.get("orderDate")%></strong></div>
                <div><small>Transport Method</small><strong><%=o.get("deliveryMethod")%></strong></div>
                <div><small>Order Total</small><strong>Rs. <%=String.format("%.2f", (double)o.get("totalAmount"))%></strong></div>
            </div>

            <div class="order-items-mini">
                <h4>Medicine Items</h4>
                <%
                String details = String.valueOf(o.get("itemDetails"));
                if(details != null && !"null".equals(details) && !details.trim().isEmpty()) {
                    String[] orderItems = details.split("\\|\\|");
                    for(String itemDetail : orderItems) {
                        String[] parts = itemDetail.split("::", -1);
                        String image = parts.length > 0 && !parts[0].trim().isEmpty() ? parts[0] : "medicine.svg";
                        String name = parts.length > 1 ? parts[1] : "Medicine";
                        String qty = parts.length > 2 ? parts[2] : "0";
                        String itemStatus = parts.length > 3 ? parts[3] : status;
                        String expectedAt = parts.length > 5 ? parts[5] : "";
                %>
                <div class="order-mini-item">
                    <img src="../assets/images/<%=image%>" alt="<%=name%>">
                    <div>
                        <strong><%=name%></strong>
                        <small>Qty: <%=qty%> | Status: <%=itemStatus%></small>
                        <% if(expectedAt != null && !expectedAt.trim().isEmpty()) { %>
                            <small>Expected delivery: <%=expectedAt%></small>
                        <% } %>
                    </div>
                </div>
                <% } } else { %>
                    <p class="muted"><%=o.get("items")%></p>
                <% } %>
            </div>
        </article>
        <% } %>
    </div>
<% } %>
<%@ include file="../WEB-INF/footer.jsp" %>
