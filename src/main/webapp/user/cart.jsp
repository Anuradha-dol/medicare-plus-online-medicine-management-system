<%@ page import="com.medicare.dao.CartOrderDAO,java.util.*" %>
<%!
private boolean hasDeliveryMethod(Object deliveryMethods, String method) {
    if (deliveryMethods == null || method == null) return false;
    String[] methods = String.valueOf(deliveryMethods).split(",");
    for (String value : methods) {
        if (method.equals(value.trim())) return true;
    }
    return false;
}
%>
<%@ include file="../WEB-INF/auth.jsp" %>
<% if(!"user".equals(authUser.getRole())) { response.sendRedirect(authHome); return; } %>
<%
CartOrderDAO dao = new CartOrderDAO();
List<Map<String,Object>> cart = dao.getCart((int)session.getAttribute("userId"));
double total = 0;
String[][] deliveryOptions = {
        {"Standard Medical Courier", "Reliable medicine courier for normal pharmacy orders."},
        {"Express Medical Courier", "Priority medical courier for urgent medicine delivery."},
        {"MediCare Delivery Service", "Delivery by the MediCare partner service network."}
};
Map<String, Boolean> deliveryAvailability = new LinkedHashMap<>();
for (String[] option : deliveryOptions) {
    deliveryAvailability.put(option[0], !cart.isEmpty());
}
for (Map<String,Object> item : cart) {
    for (String[] option : deliveryOptions) {
        if (!hasDeliveryMethod(item.get("deliveryMethods"), option[0])) {
            deliveryAvailability.put(option[0], false);
        }
    }
}
String firstAvailableDelivery = "";
for (String[] option : deliveryOptions) {
    if (Boolean.TRUE.equals(deliveryAvailability.get(option[0]))) {
        firstAvailableDelivery = option[0];
        break;
    }
}
boolean hasAvailableDelivery = !firstAvailableDelivery.isEmpty();
%>
<%@ include file="../WEB-INF/header.jsp" %>
<div class="card">
    <h2>My Cart</h2>
    <table>
        <tr><th>Medicine</th><th>Category</th><th>Price</th><th>Stock</th><th>Availability</th><th>Qty</th><th>Subtotal</th><th>Action</th></tr>
        <% for(Map<String,Object> item: cart) { total += (double)item.get("subtotal"); String image = String.valueOf(item.get("image")); if(image == null || "null".equals(image) || image.trim().isEmpty()) image = "medicine.svg"; %>
        <tr>
            <td>
                <div class="cart-medicine">
                    <img class="cart-item-image" src="../assets/images/<%=image%>" alt="<%=item.get("name")%>">
                    <strong><%=item.get("name")%></strong>
                </div>
            </td>
            <td><%=item.get("category")%></td>
            <td>Rs. <%=String.format("%.2f", (double)item.get("price"))%></td>
            <td><span class="badge <%=((int)item.get("stock"))<=15?"low":""%>"><%=item.get("stock")%></span></td>
            <td><span class="badge <%=((Boolean)item.get("orderable")) ? "" : "low"%>"><%=((Boolean)item.get("orderable")) ? "Available" : "Unavailable"%></span></td>
            <td>
                <form action="cart" method="post" style="display:flex;gap:8px">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="cartId" value="<%=item.get("cartId")%>">
                    <input class="cart-quantity-input" data-unit-price="<%=item.get("price")%>" type="number" name="quantity" value="<%=item.get("quantity")%>" min="1" max="<%=item.get("stock")%>" style="max-width:90px">
                    <button>Update</button>
                </form>
            </td>
            <td>Rs. <span class="cart-row-subtotal"><%=String.format("%.2f", (double)item.get("subtotal"))%></span></td>
            <td><a class="btn danger" onclick="return confirmDelete()" href="cart?action=remove&id=<%=item.get("cartId")%>">Remove</a></td>
        </tr>
        <% } %>
        <% if(cart.isEmpty()) { %>
        <tr><td colspan="8">Your cart is empty.</td></tr>
        <% } %>
    </table>
    <p class="muted">Changing quantity updates the visible total immediately. Click Update to save it to your cart.</p>
    <h2>Total: Rs. <span id="cartGrandTotal"><%=String.format("%.2f", total)%></span></h2>
    <% if(!cart.isEmpty()) { %>
        <form action="cart" method="post" class="checkout-panel">
            <input type="hidden" name="action" value="checkout">
            <div>
                <span class="auth-kicker">Delivery</span>
                <h3>Choose transport method</h3>
                <p class="muted">This method will appear on the order receipt for the customer and pharmacist.</p>
            </div>
            <div class="checkout-fields">
                <label>Transport Method</label>
                <div class="delivery-option-grid">
                    <% for(String[] option : deliveryOptions) {
                        String method = option[0];
                        boolean available = Boolean.TRUE.equals(deliveryAvailability.get(method));
                    %>
                    <label class="delivery-option <%= available ? "" : "disabled" %>">
                        <input type="radio" name="deliveryMethod" value="<%=method%>" <%= available ? "required" : "disabled" %> <%= method.equals(firstAvailableDelivery) ? "checked" : "" %>>
                        <span><%=method%></span>
                        <small><%= available ? option[1] : "Not enabled by the pharmacist for this cart." %></small>
                    </label>
                    <% } %>
                </div>
                <% if(!hasAvailableDelivery) { %>
                    <p class="muted warning-note">No common transport method is available for every medicine in this cart. Remove one item or ask the pharmacist to enable a shared delivery service.</p>
                <% } %>
                <button class="success" <%= hasAvailableDelivery ? "" : "disabled" %>>Place Order</button>
            </div>
        </form>
    <% } %>
    <a class="btn" href="medicines.jsp">Continue Shopping</a>
</div>
<%@ include file="../WEB-INF/footer.jsp" %>
