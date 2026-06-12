package com.medicare.servlet.admin;

import com.medicare.config.AuthUtil;
import com.medicare.dao.UserDAO;
import com.medicare.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.net.URLEncoder;

@WebServlet("/admin/pharmacists")
public class PharmacistServlet extends HttpServlet {
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.sendRedirect("manage-pharmacists.jsp");
    }

    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        User admin = AuthUtil.requireRole(req, resp, "admin");
        if (admin == null) return;

        String action = req.getParameter("action");
        int id = parseId(req.getParameter("id"));
        if (id <= 0) {
            resp.sendRedirect("manage-pharmacists.jsp?error=" + encode("Invalid pharmacist selected."));
            return;
        }

        UserDAO dao = new UserDAO();
        boolean ok = false;
        String successMessage = "";

        if ("approve".equals(action)) {
            ok = dao.approvePharmacist(id);
            successMessage = "Pharmacist approved successfully.";
        } else if ("delete".equals(action)) {
            ok = dao.deleteByRole(id, "pharmacist");
            successMessage = "Pharmacist deleted successfully.";
        }

        if (ok) {
            resp.sendRedirect("manage-pharmacists.jsp?success=" + encode(successMessage));
        } else {
            resp.sendRedirect("manage-pharmacists.jsp?error=" + encode("Action failed."));
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
