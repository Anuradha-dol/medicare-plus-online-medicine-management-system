package com.medicare.servlet.user;

import com.medicare.config.AuthUtil;
import com.medicare.dao.OrderIssueDAO;
import com.medicare.model.User;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.net.URLEncoder;

@WebServlet("/user/order-issues")
public class OrderIssueServlet extends HttpServlet {
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        User user = AuthUtil.requireRole(req, resp, "user");
        if (user == null) return;

        int orderId = parseInt(req.getParameter("orderId"), -1);
        boolean ok = orderId > 0 && new OrderIssueDAO().addIssue(
                user.getUserId(),
                orderId,
                req.getParameter("issueType"),
                req.getParameter("message")
        );

        resp.sendRedirect("orders.jsp?" + (ok
                ? "success=" + encode("Your message was sent to admin.")
                : "error=" + encode("Message failed. Select a valid order and enter a message.")));
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
