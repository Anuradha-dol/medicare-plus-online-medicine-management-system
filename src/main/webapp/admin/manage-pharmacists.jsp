<%@ page import="com.medicare.dao.UserDAO,com.medicare.model.User,java.util.*" %>
<%!
private String show(String value) {
    return value == null || value.trim().isEmpty() ? "-" : value;
}
%>
<%@ include file="../WEB-INF/auth.jsp" %>
<% if(!"admin".equals(authUser.getRole())) { response.sendRedirect(authHome); return; } %>
<%
UserDAO dao = new UserDAO();
List<User> pharmacists = dao.getByRole("pharmacist");
%>
<%@ include file="../WEB-INF/header.jsp" %>
<div class="card">
    <h2>Manage Pharmacists</h2>
    <p class="muted">Pharmacists must register from the sign-up page. Admin can review, approve, and delete pharmacist accounts.</p>

    <table>
        <tr>
            <th>Name</th>
            <th>Email</th>
            <th>Phone</th>
            <th>Address</th>
            <th>Pharmacy</th>
            <th>Pharmacy Address</th>
            <th>Status</th>
            <th>Action</th>
        </tr>
        <% for(User u: pharmacists) { %>
        <tr>
            <td><%=show(u.getName())%></td>
            <td><%=show(u.getEmail())%></td>
            <td><%=show(u.getPhone())%></td>
            <td><%=show(u.getAddress())%></td>
            <td><%=show(u.getPharmacyName())%></td>
            <td><%=show(u.getPharmacyAddress())%></td>
            <td><span class="badge <%= "pending".equals(u.getApprovalStatus()) ? "pending" : "" %>"><%=show(u.getApprovalStatus())%></span></td>
            <td>
                <% if("pending".equals(u.getApprovalStatus())) { %>
                    <form action="pharmacists" method="post" class="inline-form">
                        <input type="hidden" name="action" value="approve">
                        <input type="hidden" name="id" value="<%=u.getUserId()%>">
                        <button class="success" type="submit">Approve</button>
                    </form>
                <% } %>
                <form action="pharmacists" method="post" class="inline-form" onsubmit="return confirmDelete()">
                    <input type="hidden" name="action" value="delete">
                    <input type="hidden" name="id" value="<%=u.getUserId()%>">
                    <button class="danger" type="submit">Delete</button>
                </form>
            </td>
        </tr>
        <% } %>
        <% if(pharmacists.isEmpty()) { %>
        <tr><td colspan="8">No pharmacists registered yet.</td></tr>
        <% } %>
    </table>
    <a class="btn" href="dashboard.jsp">Back</a>
</div>
<%@ include file="../WEB-INF/footer.jsp" %>
