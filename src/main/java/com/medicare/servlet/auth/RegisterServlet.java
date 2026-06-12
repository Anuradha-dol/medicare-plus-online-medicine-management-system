package com.medicare.servlet.auth;

import com.medicare.dao.UserDAO;
import com.medicare.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.net.URLEncoder;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String selectedRole = req.getParameter("role");
        String role = "pharmacist".equals(selectedRole) ? "pharmacist" : "user";

        User user = new User();
        user.setName(trim(req.getParameter("name")));
        user.setEmail(trim(req.getParameter("email")));
        user.setPassword(req.getParameter("password"));
        user.setPhone(trim(req.getParameter("phone")));
        user.setAddress(trim(req.getParameter("address")));
        user.setRole(role);

        if ("pharmacist".equals(role)) {
            user.setPharmacyName(trim(req.getParameter("pharmacyName")));
            user.setPharmacyAddress(trim(req.getParameter("pharmacyAddress")));
            if (isBlank(user.getPharmacyName()) || isBlank(user.getPharmacyAddress())) {
                resp.sendRedirect("register.jsp?error=" + encode("Pharmacy name and pharmacy address are required for pharmacist registration."));
                return;
            }
        }

        if (isBlank(user.getName()) || isBlank(user.getEmail()) || isBlank(user.getPassword())) {
            resp.sendRedirect("register.jsp?error=" + encode("Name, email, and password are required."));
            return;
        }

        boolean ok = new UserDAO().register(user);
        if(ok) {
            String message = "pharmacist".equals(role)
                    ? "Registered successfully. Your pharmacist account is waiting for admin approval."
                    : "Registered successfully. Please login.";
            resp.sendRedirect("login.jsp?success=" + encode(message));
        } else {
            resp.sendRedirect("register.jsp?error=" + encode("Registration failed. The email may already be registered."));
        }
    }

    private String trim(String value) {
        return value == null ? "" : value.trim();
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }

    private String encode(String value) throws IOException {
        return URLEncoder.encode(value, "UTF-8");
    }
}
