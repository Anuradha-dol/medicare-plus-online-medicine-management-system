<%@ page import="com.medicare.dao.OrderIssueDAO,java.util.*" %>
<%@ include file="../WEB-INF/auth.jsp" %>
<% if(!"admin".equals(authUser.getRole())) { response.sendRedirect(authHome); return; } %>
<%
List<Map<String,Object>> issues = new OrderIssueDAO().getAll();
%>
<%@ include file="../WEB-INF/header.jsp" %>
<div class="card order-page-head">
    <div>
        <span class="auth-kicker">Customer Support</span>
        <h2>Order Messages</h2>
        <p class="muted">Review customer delivery messages, update the status, and send a professional admin response.</p>
    </div>
    <a class="btn" href="dashboard.jsp">Back</a>
</div>

<% if(issues.isEmpty()) { %>
    <div class="card"><p>No customer order messages yet.</p></div>
<% } else { %>
    <div class="message-board">
        <% for(Map<String,Object> issue : issues) {
            String issueStatus = String.valueOf(issue.get("issueStatus"));
            String statusClass = issueStatus.toLowerCase(Locale.ROOT).replace(" ","-");
        %>
        <article class="message-card">
            <div class="message-card-head">
                <div>
                    <span class="auth-kicker"><%=issue.get("issueType")%></span>
                    <h3>Order #<%=issue.get("orderId")%></h3>
                    <p><%=issue.get("customerName")%> | <%=issue.get("customerEmail")%></p>
                </div>
                <span class="badge status-<%=statusClass%>"><%=issueStatus%></span>
            </div>

            <div class="order-meta-grid">
                <div><small>Order Status</small><strong><%=issue.get("orderStatus")%></strong></div>
                <div><small>Transport Method</small><strong><%=issue.get("deliveryMethod")%></strong></div>
                <div><small>Message Sent</small><strong><%=issue.get("createdAt")%></strong></div>
            </div>

            <div class="customer-message">
                <strong>Customer Message</strong>
                <p><%=issue.get("message")%></p>
            </div>

            <form action="order-messages" method="post" class="admin-response-form">
                <input type="hidden" name="issueId" value="<%=issue.get("issueId")%>">
                <label>Message Status</label>
                <select name="issueStatus" required>
                    <option value="Open" <%= "Open".equals(issueStatus) ? "selected" : "" %>>Open</option>
                    <option value="In Review" <%= "In Review".equals(issueStatus) ? "selected" : "" %>>In Review</option>
                    <option value="Resolved" <%= "Resolved".equals(issueStatus) ? "selected" : "" %>>Resolved</option>
                    <option value="Closed" <%= "Closed".equals(issueStatus) ? "selected" : "" %>>Closed</option>
                </select>
                <label>Admin Response</label>
                <textarea name="adminResponse" placeholder="Example: We are checking with the pharmacist and will update you shortly."><%=issue.get("adminResponse") == null ? "" : issue.get("adminResponse")%></textarea>
                <button type="submit">Update Response</button>
            </form>
        </article>
        <% } %>
    </div>
<% } %>
<%@ include file="../WEB-INF/footer.jsp" %>
