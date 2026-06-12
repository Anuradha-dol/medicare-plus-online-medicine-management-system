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
