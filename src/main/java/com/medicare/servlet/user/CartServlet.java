package com.medicare.servlet.user;

import com.medicare.config.AuthUtil;
import com.medicare.dao.CartOrderDAO;
import com.medicare.model.User;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.net.URLEncoder;

@WebServlet("/user/cart")
public class CartServlet extends HttpServlet {
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        User user = AuthUtil.requireRole(req, resp, "user");
        if (user == null) return;

        CartOrderDAO dao = new CartOrderDAO();
        String action = req.getParameter("action");

        if ("remove".equals(action)) {
            dao.removeCart(parseInt(req.getParameter("id"), -1), user.getUserId());
        }
        resp.sendRedirect("cart.jsp");
    }

    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        User user = AuthUtil.requireRole(req, resp, "user");
        if (user == null) return;

        CartOrderDAO dao = new CartOrderDAO();
        int userId = user.getUserId();
        String action = req.getParameter("action");

        if ("add".equals(action)) {
            boolean ok = dao.addToCart(userId, parseInt(req.getParameter("medicineId"), -1), parseInt(req.getParameter("quantity"), 1));
            resp.sendRedirect("medicines.jsp?" + (ok ? "success=" + encode("Medicine added to cart.") : "error=" + encode("Unable to add medicine. Check available stock.")));
        } else if ("update".equals(action)) {
            boolean ok = dao.updateCart(parseInt(req.getParameter("cartId"), -1), userId, parseInt(req.getParameter("quantity"), 1));
            resp.sendRedirect("cart.jsp?" + (ok ? "success=" + encode("Cart updated.") : "error=" + encode("Unable to update cart. Check available stock.")));
        } else if ("checkout".equals(action)) {
            boolean ok = dao.placeOrder(userId, req.getParameter("deliveryMethod"));
            if (ok) {
                resp.sendRedirect("orders.jsp?success=" + encode("Order placed successfully."));
            } else {
                resp.sendRedirect("cart.jsp?error=" + encode("Order failed. Please check stock and choose an available transport method."));
            }
        } else {
            resp.sendRedirect("cart.jsp");
        }
    }

    private int parseInt(String value, int fallback) {
        try {
            return Integer.parseInt(value);
        } catch (Exception e) {
            return fallback;
        }
    }

    private String encode(String value) throws IOException {
        return URLEncoder.encode(value, "UTF-8");
    }
}
