package com.medicare.servlet.pharmacist;

import com.medicare.config.AuthUtil;
import com.medicare.dao.CartOrderDAO;
import com.medicare.model.User;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.net.URLEncoder;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.time.format.DateTimeParseException;

@WebServlet("/pharmacist/update-order")
public class OrderStatusServlet extends HttpServlet {
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        User pharmacist = AuthUtil.requireRole(req, resp, "pharmacist");
        if (pharmacist == null) return;

        int orderId = parseInt(req.getParameter("orderId"), -1);
        String status = req.getParameter("status");
        Timestamp expectedDeliveryAt = parseDateTime(req.getParameter("expectedDeliveryAt"));
        boolean ok = orderId > 0 && new CartOrderDAO().updateOrderStatus(
                orderId,
                status,
                pharmacist.getUserId(),
                expectedDeliveryAt
        );
        resp.sendRedirect("orders.jsp?" + (ok ? "success=" + encode("Order status updated.") : "error=" + encode(errorMessage(status))));
    }
