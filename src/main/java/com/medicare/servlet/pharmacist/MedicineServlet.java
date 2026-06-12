package com.medicare.servlet.pharmacist;

import com.medicare.config.AuthUtil;
import com.medicare.dao.MedicineDAO;
import com.medicare.model.Medicine;
import com.medicare.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.File;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.file.Paths;
import java.util.Locale;
import java.util.UUID;

@WebServlet("/pharmacist/medicines")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,
        maxFileSize = 5 * 1024 * 1024,
        maxRequestSize = 8 * 1024 * 1024
)
public class MedicineServlet extends HttpServlet {
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User pharmacist = AuthUtil.requireRole(req, resp, "pharmacist");
        if (pharmacist == null) return;

        MedicineDAO dao = new MedicineDAO();
        String action = req.getParameter("action");
        int id = parseInt(req.getParameter("id"), -1);

        if ("delete".equals(action)) {
            boolean ok = id > 0 && dao.delete(id, pharmacist.getUserId());
            resp.sendRedirect("manage-medicines.jsp?" + (ok ? "success=" + encode("Medicine deleted successfully.") : "error=" + encode("Medicine delete failed.")));
            return;
        }

        if ("edit".equals(action)) {
            Medicine medicine = id > 0 ? dao.getByIdForOwner(id, pharmacist.getUserId()) : null;
            if (medicine == null) {
                resp.sendRedirect("manage-medicines.jsp?error=" + encode("Medicine not found."));
                return;
            }
            req.setAttribute("editMedicine", medicine);
            req.getRequestDispatcher("manage-medicines.jsp").forward(req, resp);
            return;
        }

        resp.sendRedirect("manage-medicines.jsp");
    }

    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        User pharmacist = AuthUtil.requireRole(req, resp, "pharmacist");
        if (pharmacist == null) return;

        String action = req.getParameter("action");
        Medicine m = new Medicine();
        m.setName(trim(req.getParameter("name")));
        m.setCategory(trim(req.getParameter("category")));
        m.setDescription(trim(req.getParameter("description")));
        m.setPrice(parseDouble(req.getParameter("price"), -1));
        m.setQuantity(parseInt(req.getParameter("quantity"), -1));
        m.setExpiryDate(trim(req.getParameter("expiryDate")));
        String imagePath = saveImage(req);
        if (!isBlank(imagePath)) {
            m.setImage(imagePath);
        }
        m.setDeliveryMethods(joinDeliveryMethods(req.getParameterValues("deliveryMethods")));

        if (isBlank(m.getName()) || isBlank(m.getCategory()) || m.getPrice() < 0 || m.getQuantity() < 0) {
            resp.sendRedirect("manage-medicines.jsp?error=" + encode("Medicine name, category, price, and quantity are required."));
            return;
        }
        if (isBlank(m.getDeliveryMethods())) {
            resp.sendRedirect("manage-medicines.jsp?error=" + encode("Select at least one medicine delivery method."));
            return;
        }

        MedicineDAO dao = new MedicineDAO();
        boolean ok;
        if ("update".equals(action)) {
            m.setMedicineId(parseInt(req.getParameter("medicineId"), -1));
            ok = m.getMedicineId() > 0 && dao.update(m, pharmacist.getUserId());
        } else {
            ok = dao.add(m, pharmacist.getUserId());
        }

        if (ok) {
            resp.sendRedirect("manage-medicines.jsp?success=" + encode("Medicine saved successfully."));
        } else {
            resp.sendRedirect("manage-medicines.jsp?error=" + encode("Medicine save failed."));
        }
    }
