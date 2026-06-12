package com.medicare.servlet.admin;

import com.medicare.config.AuthUtil;
import com.medicare.dao.OrderIssueDAO;
import com.medicare.model.User;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.net.URLEncoder;

@WebServlet("/admin/order-messages")
public class OrderIssueServlet extends HttpServlet {
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        User admin = AuthUtil.requireRole(req, resp, "admin");
        if (admin == null) return;

        int issueId = parseInt(req.getParameter("issueId"), -1);
        boolean ok = issueId > 0 && new OrderIssueDAO().updateResponse(
                issueId,
                req.getParameter("issueStatus"),
                req.getParameter("adminResponse")
        );

        resp.sendRedirect("order-messages.jsp?" + (ok
                ? "success=" + encode("Customer message updated.")
                : "error=" + encode("Unable to update customer message.")));
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
