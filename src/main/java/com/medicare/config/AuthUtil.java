package com.medicare.config;

import com.medicare.model.User;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

public class AuthUtil {
    public static User requireRole(HttpServletRequest req, HttpServletResponse resp, String role) throws IOException {
        HttpSession session = req.getSession(false);
        User user = session == null ? null : (User) session.getAttribute("user");

        if (user == null) {
            rememberReturnUrl(req);
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return null;
        }

        if (!role.equals(user.getRole())) {
            resp.sendRedirect(home(req, user));
            return null;
        }

        return user;
    }

    private static void rememberReturnUrl(HttpServletRequest req) {
        if (!"GET".equalsIgnoreCase(req.getMethod())) return;

        String url = req.getRequestURI();
        String query = req.getQueryString();
        if (query != null && !query.trim().isEmpty()) {
            url += "?" + query;
        }
        req.getSession().setAttribute("returnUrl", url);
    }

    public static String home(HttpServletRequest req, User user) {
        String base = req.getContextPath();
        if ("admin".equals(user.getRole())) return base + "/admin/dashboard.jsp";
        if ("pharmacist".equals(user.getRole())) return base + "/pharmacist/dashboard.jsp";
        return base + "/user/dashboard.jsp";
    }
}
