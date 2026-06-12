package com.medicare.config;

import java.sql.Connection;
import java.sql.DriverManager;

public class DBConnection {
    private static final String URL = "jdbc:mysql://localhost:3306/online_medicine_db";
    private static final String USER = "root";
    private static final String PASSWORD = "Anu@20021214"; // Put your MySQL password here if you have one.

    public static Connection getConnection() throws Exception {
        Class.forName("com.mysql.cj.jdbc.Driver");
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}
