<%@ page import="com.medicare.dao.CartOrderDAO,com.medicare.dao.MedicineDAO,com.medicare.model.Medicine,java.util.*" %>
<%@ include file="../WEB-INF/auth.jsp" %>
<% if(!"pharmacist".equals(authUser.getRole()) && !"admin".equals(authUser.getRole())) { response.sendRedirect(authHome); return; } %>
<%
CartOrderDAO orderDAO = new CartOrderDAO();
MedicineDAO medDAO = new MedicineDAO();
boolean adminView = "admin".equals(authUser.getRole());
Map<String,Object> a = adminView ? orderDAO.analytics() : orderDAO.analytics(authUser.getUserId());
List<Medicine> low = adminView ? medDAO.lowStock() : medDAO.lowStock(authUser.getUserId());
%>
<%@ include file="../WEB-INF/header.jsp" %>
<div class="card">
    <h2><%= adminView ? "Global Stock & Sales Analytics" : "My Stock & Sales Analytics" %></h2>
    <div class="grid">
        <div class="stat"><small>Total Orders</small><strong><%=a.get("totalOrders")%></strong></div>
        <div class="stat"><small>Total Sales</small><strong>Rs. <%=a.get("totalSales")%></strong></div>
        <div class="stat"><small>Pending Orders</small><strong><%=a.get("pendingOrders")%></strong></div>
        <div class="stat"><small>Low Stock Items</small><strong><%=a.get("lowStock")%></strong></div>
        <div class="stat"><small>Most Ordered Medicine</small><strong><%=a.get("topMedicine")%></strong></div>
    </div>

    <h3>Low Stock Alerts</h3>
    <table>
        <tr><th>Medicine</th><th>Category</th><th>Current Stock</th><th>Expiry</th></tr>
        <% for(Medicine m: low) { %>
        <tr>
            <td><%=m.getName()%></td>
            <td><%=m.getCategory()%></td>
            <td><span class="badge low"><%=m.getQuantity()%></span></td>
            <td><%=m.getExpiryDate()%></td>
        </tr>
        <% } %>
    </table>
    <a class="btn" href="<%= adminView ? "../admin/dashboard.jsp" : "dashboard.jsp" %>">Back</a>
</div>
<%@ include file="../WEB-INF/footer.jsp" %>
