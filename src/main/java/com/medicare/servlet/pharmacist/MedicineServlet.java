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

    private String trim(String value) {
        return value == null ? "" : value.trim();
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }

    private int parseInt(String value, int fallback) {
        try {
            return Integer.parseInt(value);
        } catch (Exception e) {
            return fallback;
        }
    }

    private double parseDouble(String value, double fallback) {
        try {
            return Double.parseDouble(value);
        } catch (Exception e) {
            return fallback;
        }
    }

    private String saveImage(HttpServletRequest req) throws IOException {
        try {
            Part imagePart = req.getPart("image");
            if (imagePart == null || imagePart.getSize() == 0) return "";

            String contentType = imagePart.getContentType();
            if (contentType == null || !contentType.toLowerCase(Locale.ROOT).startsWith("image/")) {
                return "";
            }

            String submittedName = Paths.get(imagePart.getSubmittedFileName()).getFileName().toString();
            String extension = extension(submittedName);
            if (!isAllowedExtension(extension)) return "";

            String fileName = "medicine-" + System.currentTimeMillis() + "-" + UUID.randomUUID().toString().substring(0, 8) + extension;
            String relativeDir = "assets/images/medicines";
            String uploadDir = req.getServletContext().getRealPath("/" + relativeDir);
            if (uploadDir == null) return "";

            File directory = new File(uploadDir);
            if (!directory.exists() && !directory.mkdirs()) return "";

            imagePart.write(new File(directory, fileName).getAbsolutePath());
            return "medicines/" + fileName;
        } catch (ServletException e) {
            throw new IOException("Medicine image upload failed", e);
        }
    }

    private String extension(String fileName) {
        int dot = fileName == null ? -1 : fileName.lastIndexOf('.');
        return dot >= 0 ? fileName.substring(dot).toLowerCase(Locale.ROOT) : ".jpg";
    }

    private boolean isAllowedExtension(String extension) {
        return ".jpg".equals(extension) || ".jpeg".equals(extension)
                || ".png".equals(extension) || ".gif".equals(extension)
                || ".webp".equals(extension);
    }

    private String joinDeliveryMethods(String[] selected) {
        if (selected == null || selected.length == 0) return "";

        StringBuilder methods = new StringBuilder();
        appendSelected(methods, selected, MedicineDAO.STANDARD_MEDICAL_COURIER);
        appendSelected(methods, selected, MedicineDAO.EXPRESS_MEDICAL_COURIER);
        appendSelected(methods, selected, MedicineDAO.MEDICARE_DELIVERY_SERVICE);
        return methods.toString();
    }

    private void appendSelected(StringBuilder methods, String[] selected, String allowedMethod) {
        for (String value : selected) {
            if (allowedMethod.equals(value)) {
                if (methods.length() > 0) methods.append(',');
                methods.append(allowedMethod);
                return;
            }
        }
    }

    private String encode(String value) throws IOException {
        return URLEncoder.encode(value, "UTF-8");
    }
}
