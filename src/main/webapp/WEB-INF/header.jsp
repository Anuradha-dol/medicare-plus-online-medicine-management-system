<%@ page import="com.medicare.model.User" %>
<%!
private String attr(String value) {
    if (value == null) return "";
    return value.replace("&", "&amp;")
            .replace("\"", "&quot;")
            .replace("<", "&lt;")
            .replace(">", "&gt;");
}
%>
<%
User currentUser = (User) session.getAttribute("user");
String role = currentUser != null ? currentUser.getRole() : "";
String base = request.getContextPath();
String toastSuccess = request.getParameter("success");
String toastError = request.getParameter("error");
%>
<!DOCTYPE html>
<html>
<head>
    <title>MediCare Online Pharmacy</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="<%=base%>/assets/css/style.css?v=medicare-plus-11">
    <script src="<%=base%>/assets/js/main.js?v=medicare-plus-11"></script>
</head>
<body class="<%= currentUser == null ? "public-site" : "app-site" %>">
<div id="toastSource" data-success="<%=attr(toastSuccess)%>" data-error="<%=attr(toastError)%>"></div>
<div class="nav">
    <a class="brand" href="<%=base%>/index.jsp">
        <span class="brand-mark"><span></span></span>
        <span class="brand-copy">
            <strong>MediCare <em>Plus</em></strong>
            <small>Online Medicine System</small>
        </span>
    </a>
    <div class="nav-links">
        <% if(currentUser == null) { %>
            <a class="nav-link active" href="<%=base%>/index.jsp">Home</a>
            <a class="nav-link" href="<%=base%>/index.jsp#medicines">Medicines</a>
            <a class="nav-link" href="<%=base%>/index.jsp#roles">Categories</a>
            <a class="nav-link" href="<%=base%>/index.jsp#how">How It Works</a>
            <a class="nav-link" href="<%=base%>/index.jsp#about">About Us</a>
            <a class="btn ghost" href="<%=base%>/login.jsp">Login</a>
            <a class="btn success" href="<%=base%>/register.jsp">Sign Up</a>
        <% } else if("admin".equals(role)) { %>
            <span class="session-pill">Hello, <%=currentUser.getName()%></span>
            <a class="nav-link active" href="<%=base%>/admin/dashboard.jsp">Dashboard</a>
            <a class="nav-link" href="<%=base%>/admin/manage-users.jsp">Users</a>
            <a class="nav-link" href="<%=base%>/admin/manage-pharmacists.jsp">Pharmacists</a>
            <a class="nav-link" href="<%=base%>/admin/order-messages.jsp">Messages</a>
            <a href="<%=base%>/logout" class="btn danger">Logout</a>
        <% } else if("pharmacist".equals(role)) { %>
            <span class="session-pill">Hello, <%=currentUser.getName()%></span>
            <a class="nav-link active" href="<%=base%>/pharmacist/dashboard.jsp">Dashboard</a>
            <a class="nav-link" href="<%=base%>/pharmacist/manage-medicines.jsp">Medicines</a>
            <a class="nav-link" href="<%=base%>/pharmacist/orders.jsp">Orders</a>
            <a href="<%=base%>/logout" class="btn danger">Logout</a>
        <% } else { %>
            <span class="session-pill">Hello, <%=currentUser.getName()%></span>
            <a class="nav-link active" href="<%=base%>/user/dashboard.jsp">Dashboard</a>
            <a class="nav-link" href="<%=base%>/user/medicines.jsp">Medicines</a>
            <a class="nav-link" href="<%=base%>/user/cart.jsp">Cart</a>
            <a href="<%=base%>/logout" class="btn danger">Logout</a>
        <% } %>
    </div>
</div>
<div class="container">
