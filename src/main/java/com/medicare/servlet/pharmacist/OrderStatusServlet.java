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
