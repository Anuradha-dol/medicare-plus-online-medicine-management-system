<%@ page import="com.medicare.dao.MedicineDAO,com.medicare.model.Medicine,java.util.*" %>
<%@ include file="../WEB-INF/auth.jsp" %>
<% if(!"user".equals(authUser.getRole())) { response.sendRedirect(authHome); return; } %>
<%
String search = request.getParameter("search");
List<Medicine> medicines = new MedicineDAO().getAvailable(search);
%>
<%@ include file="../WEB-INF/header.jsp" %>
<div class="card">
    <h2>Browse Medicines</h2>
    <form method="get" style="display:flex;gap:10px">
        <input name="search" placeholder="Search medicine or category" value="<%= search != null ? search : "" %>">
        <button>Search</button>
    </form>
</div>

<div class="product-grid">
    <% for(Medicine m: medicines) { %>
    <div class="product">
        <img src="../assets/images/<%=m.getImage()%>" alt="<%=m.getName()%>">
        <div class="product-body">
            <span class="badge"><%=m.getCategory()%></span>
            <h3><%=m.getName()%></h3>
            <p><%=m.getDescription()%></p>
            <p class="price">Unit Price: Rs. <span><%=String.format("%.2f", m.getPrice())%></span></p>
            <p>Stock: <span class="badge <%=m.getQuantity()<=15?"low":""%>"><%=m.getQuantity()%></span></p>
            <% if(m.getQuantity() > 0) { %>
                <form action="cart" method="post" class="medicine-order-form" data-unit-price="<%=m.getPrice()%>">
                    <input type="hidden" name="action" value="add">
                    <input type="hidden" name="medicineId" value="<%=m.getMedicineId()%>">
                    <label>Quantity</label>
                    <input class="quantity-input" type="number" name="quantity" value="1" min="1" max="<%=m.getQuantity()%>" required>
                    <div class="live-total">Total: Rs. <span class="line-total"><%=String.format("%.2f", m.getPrice())%></span></div>
                    <button class="success">Add to Cart</button>
                </form>
            <% } else { %>
                <span class="badge low">Out of Stock</span>
            <% } %>
        </div>
    </div>
    <% } %>
    <% if(medicines.isEmpty()) { %>
    <div class="card">
        <p>No available medicines found.</p>
    </div>
    <% } %>
</div>
<%@ include file="../WEB-INF/footer.jsp" %>
