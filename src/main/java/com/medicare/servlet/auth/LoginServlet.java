package com.medicare.servlet.auth;

import com.medicare.dao.UserDAO;
import com.medicare.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.net.URLEncoder;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = new UserDAO().login(req.getParameter("email"), req.getParameter("password"));

        if (user != null) {
            if ("pharmacist".equals(user.getRole()) && !user.isApproved()) {
                resp.sendRedirect("login.jsp?error=" + URLEncoder.encode("Your pharmacist account is waiting for admin approval.", "UTF-8"));
                return;
            }

            HttpSession session = req.getSession();
            session.setAttribute("user", user);
            session.setAttribute("userId", user.getUserId());
            session.setAttribute("role", user.getRole());
            session.setAttribute("name", user.getName());
            session.setMaxInactiveInterval(4 * 60 * 60);

            String destination = destination(req, session, user);
            resp.sendRedirect(addSuccess(destination, "Login successful. Welcome back, " + user.getName() + "."));
        } else {
            resp.sendRedirect("login.jsp?error=" + URLEncoder.encode("Invalid email or password", "UTF-8"));
        }
    }

    private String destination(HttpServletRequest req, HttpSession session, User user) {
        Object returnUrl = session.getAttribute("returnUrl");
        session.removeAttribute("returnUrl");

        String url = returnUrl == null ? "" : String.valueOf(returnUrl);
        if (isAllowedReturnUrl(req, user, url)) return url;

        String base = req.getContextPath();
        if ("admin".equals(user.getRole())) return base + "/admin/dashboard.jsp";
        if ("pharmacist".equals(user.getRole())) return base + "/pharmacist/dashboard.jsp";
        return base + "/user/dashboard.jsp";
    }

    private boolean isAllowedReturnUrl(HttpServletRequest req, User user, String url) {
        if (url == null || url.trim().isEmpty()) return false;

        String base = req.getContextPath();
        if ("admin".equals(user.getRole())) return url.startsWith(base + "/admin/");
        if ("pharmacist".equals(user.getRole())) return url.startsWith(base + "/pharmacist/");
        return url.startsWith(base + "/user/");
    }

    private String addSuccess(String destination, String message) throws IOException {
        String separator = destination.contains("?") ? "&" : "?";
        return destination + separator + "success=" + encode(message);
    }

    private String encode(String value) throws IOException {
        return URLEncoder.encode(value, "UTF-8");
    }
}
