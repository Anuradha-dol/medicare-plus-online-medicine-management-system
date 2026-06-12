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
List<User> users = dao.getByRole("user");
%>
<%@ include file="../WEB-INF/header.jsp" %>
<div class="card">
    <h2>Manage Users</h2>
    <p class="muted">Users must register from the sign-up page. Admin can view and delete user accounts only.</p>

    <table>
        <tr><th>Name</th><th>Email</th><th>Phone</th><th>Address</th><th>Action</th></tr>
        <% for(User u: users) { %>
        <tr>
            <td><%=show(u.getName())%></td>
            <td><%=show(u.getEmail())%></td>
            <td><%=show(u.getPhone())%></td>
            <td><%=show(u.getAddress())%></td>
            <td>
                <form action="users" method="post" class="inline-form" onsubmit="return confirmDelete()">
                    <input type="hidden" name="action" value="delete">
                    <input type="hidden" name="id" value="<%=u.getUserId()%>">
                    <button class="danger" type="submit">Delete</button>
                </form>
            </td>
        </tr>
        <% } %>
        <% if(users.isEmpty()) { %>
        <tr><td colspan="5">No users registered yet.</td></tr>
        <% } %>
    </table>
    <a class="btn" href="dashboard.jsp">Back</a>
</div>
<%@ include file="../WEB-INF/footer.jsp" %>
