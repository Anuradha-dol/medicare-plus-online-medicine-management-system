<%@ page import="com.medicare.model.User" %>
<%
User authUser = (User) session.getAttribute("user");
if(authUser == null) {
    if("GET".equalsIgnoreCase(request.getMethod())) {
        String requestedUrl = request.getRequestURI();
        String requestedQuery = request.getQueryString();
        if(requestedQuery != null && !requestedQuery.trim().isEmpty()) {
            requestedUrl += "?" + requestedQuery;
        }
        session.setAttribute("returnUrl", requestedUrl);
    }
    response.sendRedirect(request.getContextPath()+"/login.jsp");
    return;
}
String authHome = request.getContextPath()+"/user/dashboard.jsp";
if("admin".equals(authUser.getRole())) {
    authHome = request.getContextPath()+"/admin/dashboard.jsp";
} else if("pharmacist".equals(authUser.getRole())) {
    authHome = request.getContextPath()+"/pharmacist/dashboard.jsp";
}
%>
