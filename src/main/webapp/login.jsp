<%@ page import="com.medicare.model.User" %>
<%
User existingUser = (User) session.getAttribute("user");
if(existingUser != null) {
    String home = request.getContextPath()+"/user/dashboard.jsp";
    if("admin".equals(existingUser.getRole())) {
        home = request.getContextPath()+"/admin/dashboard.jsp";
    } else if("pharmacist".equals(existingUser.getRole())) {
        home = request.getContextPath()+"/pharmacist/dashboard.jsp";
    }
    response.sendRedirect(home);
    return;
}
%>
<%@ include file="WEB-INF/header.jsp" %>

<section class="auth-page auth-login">
    <div class="auth-visual">
        <span class="eyebrow">Secure Medicine Access</span>
        <h1>Welcome back to MediCare Plus</h1>
        <p>Login to continue to your role-based workspace for ordering, pharmacy management, or administration.</p>
        <div class="auth-benefits">
            <div><strong>Verified Roles</strong><small>Admin, pharmacist, and customer flows</small></div>
            <div><strong>Live Stock</strong><small>Medicines managed by approved pharmacists</small></div>
            <div><strong>Order Control</strong><small>Track and update order progress</small></div>
        </div>
    </div>

    <div class="auth-panel">
        <div class="auth-card-pro">
            <span class="auth-kicker">Account Login</span>
            <h2>Sign in</h2>
            <form action="login" method="post">
                <label>Email</label>
                <input type="email" name="email" placeholder="Enter your email" required>
                <label>Password</label>
                <input type="password" name="password" placeholder="Enter your password" required>
                <button class="success full-btn" type="submit">Login</button>
            </form>
            <div class="auth-switch">
                <span>New to MediCare Plus?</span>
                <a href="register.jsp">Create account</a>
            </div>
        </div>
    </div>
</section>

<%@ include file="WEB-INF/footer.jsp" %>
