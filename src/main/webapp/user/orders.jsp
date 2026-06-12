<%@ page import="com.medicare.dao.CartOrderDAO,com.medicare.dao.OrderIssueDAO,java.util.*" %>
<%!
private String customerStatusLabel(String status) {
    if ("Approved".equals(status)) return "On The Way";
    if ("Completed".equals(status)) return "Completed";
    if ("Pending".equals(status)) return "Pending Review";
    if ("Cancelled".equals(status)) return "Cancelled";
    return status;
}

private int countOrders(List<Map<String,Object>> orders, String status) {
    int count = 0;
    for (Map<String,Object> order : orders) {
        if (status.equals(String.valueOf(order.get("orderStatus")))) count++;
    }
    return count;
}

private String text(Object value) {
    if (value == null) return "";
    String text = String.valueOf(value);
    return "null".equals(text) ? "" : text;
}
%>
<%@ include file="../WEB-INF/auth.jsp" %>
<% if(!"user".equals(authUser.getRole())) { response.sendRedirect(authHome); return; } %>
<%
List<Map<String,Object>> orders = new CartOrderDAO().getOrders((int)session.getAttribute("userId"), false);
Map<Integer,List<Map<String,Object>>> issuesByOrder = new OrderIssueDAO().getByUserGrouped(authUser.getUserId());
String[][] sections = {
        {"Pending", "Pending Orders", "Waiting for pharmacist approval and fulfillment."},
        {"Approved", "On The Way", "Approved by pharmacist and moving through delivery."},
        {"Completed", "Completed Orders", "Completed means the order has been delivered."},
        {"Cancelled", "Cancelled Orders", "Orders cancelled by the fulfillment team."}
};
%>
<%@ include file="../WEB-INF/header.jsp" %>
<div class="card order-page-head">
    <div>
        <span class="auth-kicker">Order Center</span>
        <h2>My Orders</h2>
        <p class="muted">Orders are grouped by progress. Use the message panel if delivery or medicine details need admin support.</p>
    </div>
    <a class="btn" href="dashboard.jsp">Back</a>
</div>
<% if(orders.isEmpty()) { %>
    <div class="card"><p>No orders placed yet.</p></div>
<% } else { %>
    <div class="order-filter-bar" data-order-filter-group>
        <button type="button" class="order-filter-btn active" data-order-filter="all">All <span><%=orders.size()%></span></button>
        <button type="button" class="order-filter-btn" data-order-filter="pending">Pending <span><%=countOrders(orders, "Pending")%></span></button>
        <button type="button" class="order-filter-btn" data-order-filter="approved">On The Way <span><%=countOrders(orders, "Approved")%></span></button>
        <button type="button" class="order-filter-btn" data-order-filter="completed">Completed <span><%=countOrders(orders, "Completed")%></span></button>
        <button type="button" class="order-filter-btn" data-order-filter="cancelled">Cancelled <span><%=countOrders(orders, "Cancelled")%></span></button>
    </div>
    <div class="order-status-board">
    <% for(String[] section : sections) {
        String sectionStatus = section[0];
        int sectionCount = countOrders(orders, sectionStatus);
        String sectionKey = sectionStatus.toLowerCase(Locale.ROOT);
    %>
    <section class="order-status-section status-section-<%=sectionKey%>" data-order-section="<%=sectionKey%>">
        <div class="section-heading">
            <div>
                <span class="auth-kicker"><%=customerStatusLabel(sectionStatus)%></span>
                <h3><%=section[1]%></h3>
                <p class="muted"><%=section[2]%></p>
            </div>
            <span class="section-count"><%=sectionCount%></span>
        </div>

        <div class="order-card-list">
            <% int rendered = 0; %>
            <% for(Map<String,Object> o: orders) {
                String status = String.valueOf(o.get("orderStatus"));
                if(!sectionStatus.equals(status)) continue;
                rendered++;
                String statusClass = status.toLowerCase(Locale.ROOT);
                Integer orderId = (Integer)o.get("orderId");
            %>
            <article class="order-card">
                <div class="order-card-head">
                    <div>
                        <span class="auth-kicker">Receipt</span>
                        <h3>Order #<%=orderId%></h3>
                    </div>
                    <span class="badge status-<%=statusClass%>"><%=customerStatusLabel(status)%></span>
                </div>

                <div class="order-meta-grid">
                    <div><small>Order Date & Time</small><strong><%=o.get("orderDate")%></strong></div>
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
                            <small>Qty: <%=qty%> | Status: <%=customerStatusLabel(itemStatus)%></small>
                            <% if(expectedAt != null && !expectedAt.trim().isEmpty()) { %>
                                <small>Expected delivery: <%=expectedAt%></small>
                            <% } %>
                        </div>
                    </div>
                    <% } } else { %>
                        <p class="muted"><%=o.get("items")%></p>
                    <% } %>
                </div>

                <div class="order-support-panel">
                    <h4>Message Admin About This Order</h4>
                    <form action="order-issues" method="post" class="issue-form">
                        <input type="hidden" name="orderId" value="<%=orderId%>">
                        <select name="issueType" required>
                            <option value="Delivery Problem">Delivery Problem</option>
                            <option value="Order Not Received">Order Not Received</option>
                            <option value="Order Received">Order Received</option>
                            <option value="Medicine Problem">Medicine Problem</option>
                            <option value="Other">Other</option>
                        </select>
                        <textarea name="message" placeholder="Tell admin what happened with this order" required></textarea>
                        <button type="submit">Send Message</button>
                    </form>

                    <%
                    List<Map<String,Object>> messages = issuesByOrder.get(orderId);
                    if(messages != null && !messages.isEmpty()) {
                    %>
                    <div class="issue-thread">
                        <% for(Map<String,Object> issue : messages) { %>
                        <div class="issue-message">
                            <div>
                                <strong><%=issue.get("issueType")%></strong>
                                <span class="badge status-<%=String.valueOf(issue.get("issueStatus")).toLowerCase(Locale.ROOT).replace(" ","-")%>"><%=issue.get("issueStatus")%></span>
                            </div>
                            <p><%=issue.get("message")%></p>
                            <small>Sent: <%=issue.get("createdAt")%></small>
                            <% if(!text(issue.get("adminResponse")).trim().isEmpty()) { %>
                                <div class="admin-response">
                                    <strong>Admin Response</strong>
                                    <p><%=issue.get("adminResponse")%></p>
                                    <small>Updated: <%=issue.get("respondedAt")%></small>
                                </div>
                            <% } %>
                        </div>
                        <% } %>
                    </div>
                    <% } %>
                </div>
            </article>
            <% } %>
            <% if(rendered == 0) { %>
                <div class="order-empty-state">
                    <strong>No <%=customerStatusLabel(sectionStatus).toLowerCase(Locale.ROOT)%> orders</strong>
                    <p>This section will show orders after their status changes.</p>
                </div>
            <% } %>
        </div>
    </section>
    <% } %>
    </div>
<% } %>
<%@ include file="../WEB-INF/footer.jsp" %>
