package com.medicare.servlet.admin;

import com.medicare.config.AuthUtil;
import com.medicare.dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.net.URLEncoder;

@WebServlet("/admin/users")
public class UserServlet extends HttpServlet {
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.sendRedirect("manage-users.jsp");
    }

    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        if (AuthUtil.requireRole(req, resp, "admin") == null) return;

        String action = req.getParameter("action");
        int id = parseId(req.getParameter("id"));
        if (!"delete".equals(action) || id <= 0) {
            resp.sendRedirect("manage-users.jsp?error=" + encode("Invalid user selected."));
            return;
        }

        boolean ok = new UserDAO().deleteByRole(id, "user");
        if (ok) {
            resp.sendRedirect("manage-users.jsp?success=" + encode("User deleted successfully."));
        } else {
            resp.sendRedirect("manage-users.jsp?error=" + encode("User delete failed."));
        }
    }

    private int parseId(String value) {
        try {
            return Integer.parseInt(value);
        } catch (Exception e) {
            return -1;
        }
    }

    private String encode(String value) throws IOException {
        return URLEncoder.encode(value, "UTF-8");
    }
}
