# MediCare Plus - Online Medicine Management System

MediCare Plus is a Java JSP and Servlet web application for online medicine ordering and pharmacy management. Customers can browse medicines, manage a cart, place orders, track delivery progress, and report order issues. Pharmacists can manage their own medicine inventory and process customer orders after admin approval. Admin users manage pharmacists, customers, orders, analytics, and support messages.

This repository is intended to be easy for outside users to understand, import, run, and review.

## Project Overview

- Project type: Java JSP Servlet MVC web application
- Build type: Maven WAR project
- Application artifact: `online_medicine_system`
- Database: MySQL
- Main database script: `database/online_medicine_db.sql`
- Recommended server: Apache Tomcat 10.x

## Technologies

- Java 11
- JSP
- Jakarta Servlet
- JDBC
- MySQL
- Apache Tomcat 10.x
- Maven
- HTML
- CSS
- JavaScript
- MVC architecture

## Main Roles

The system has three role-based dashboards:

- Admin
- Pharmacist
- User / Customer

Each role has separate access permissions. Unauthorized users are redirected away from pages they cannot access.

## Main Features

### Public Website

- Pharmacy-themed landing page
- Login page
- Registration page
- Customer registration
- Pharmacist registration with pharmacy name and address
- Responsive layout for desktop and mobile
- Toast and popup messages for common actions

### Admin Features

- Admin dashboard with analytics
- View and delete customers
- View, approve, and delete pharmacists
- Block pending pharmacists from logging in before approval
- View all orders
- View order status and transport method
- View customer order issues/messages
- Reply to customer messages
- Update message status: Open, In Review, Resolved, Closed

### Pharmacist Features

- Pharmacist account approval workflow
- Dashboard for inventory, orders, and sales
- Add medicines
- Upload medicine images
- Edit own medicines
- Delete own medicines
- Manage stock quantity
- Select available delivery methods per medicine:
  - Standard Medical Courier
  - Express Medical Courier
  - MediCare Delivery Service
- View orders for own medicines only
- Update order status: Pending, Approved, Completed, Cancelled
- Add expected delivery date/time when approving orders
- View low-stock alerts
- View sales and order analytics

### User Features

- Register and login without admin approval
- Browse available medicines
- Search medicines
- View medicine image, price, stock, category, and description
- Add medicines to cart
- Update cart quantity
- Remove cart items
- View live subtotal and total price
- Select only delivery methods enabled by the pharmacist
- Place orders
- View order history
- Track orders under All, Pending, On The Way, Completed, and Cancelled
- Send order-related issues to admin
- View admin response under each order

## Order Flow

1. Customer browses available medicines.
2. Customer adds medicines to the cart.
3. Customer selects quantity and a valid delivery method.
4. Customer places the order.
5. Order starts as Pending.
6. Pharmacist reviews the order.
7. Pharmacist approves the order and enters expected delivery date/time.
8. Customer sees the order as On The Way.
9. Pharmacist marks the order as Completed after delivery.
10. Customer can send an issue/message to admin if there is a problem.

## Database

The SQL script creates and seeds the database:

```sql
CREATE DATABASE IF NOT EXISTS online_medicine_db;
USE online_medicine_db;
```

Main tables:

- `users`
- `medicines`
- `cart`
- `orders`
- `order_items`
- `order_issues`

The script also inserts sample accounts and sample medicine data.

## Sample Login Accounts

All sample accounts use this password:

```text
123456
```

| Role | Email |
| --- | --- |
| Admin | `admin@gmail.com` |
| Pharmacist | `pharmacist@gmail.com` |
| Customer | `user@gmail.com` |

## Setup Requirements

Install these tools before running the project:

- JDK 11 or higher
- Maven
- MySQL Server or XAMPP MySQL
- MySQL Workbench or another MySQL client
- Apache Tomcat 10.x
- IntelliJ IDEA Ultimate, Eclipse Enterprise, or NetBeans

Recommended setup:

- IntelliJ IDEA
- Apache Tomcat 10.x
- MySQL Workbench

## How to Run

1. Clone the repository.

```bash
git clone https://github.com/Anuradha-dol/medicare-plus-online-medicine-management-system.git
```

2. Open the project folder in your IDE.

3. Wait for Maven dependencies to load.

4. Import the database script into MySQL.

```text
database/online_medicine_db.sql
```

5. Check the database connection settings in:

```text
src/main/java/com/medicare/config/DBConnection.java
```

Default connection:

```text
URL      = jdbc:mysql://localhost:3306/online_medicine_db
USER     = root
PASSWORD =
```

If your MySQL password or port is different, update `DBConnection.java`.

6. Configure Apache Tomcat 10.x in your IDE.

For IntelliJ IDEA:

- Add Configuration
- Choose Tomcat Server > Local
- Select your Tomcat installation folder
- Open the Deployment tab
- Add the WAR exploded artifact
- Use this application context:

```text
/online_medicine_system
```

7. Run Tomcat and open:

```text
http://localhost:8080/online_medicine_system/
```

## Important Project Files

These files are important and should not be removed during cleanup:

| Area | Path | Purpose |
| --- | --- | --- |
| Database script | `database/online_medicine_db.sql` | Creates tables, sample users, and sample medicine data |
| Maven config | `pom.xml` | Project dependencies and WAR build config |
| DB config | `src/main/java/com/medicare/config/DBConnection.java` | MySQL connection settings |
| Auth utility | `src/main/java/com/medicare/config/AuthUtil.java` | Role access and login redirects |
| Password utility | `src/main/java/com/medicare/config/PasswordUtil.java` | Password hashing |
| Medicine DAO | `src/main/java/com/medicare/dao/MedicineDAO.java` | Medicine database operations |
| Cart/order DAO | `src/main/java/com/medicare/dao/CartOrderDAO.java` | Cart, order, delivery, and analytics operations |
| User DAO | `src/main/java/com/medicare/dao/UserDAO.java` | User and pharmacist database operations |
| Order issue DAO | `src/main/java/com/medicare/dao/OrderIssueDAO.java` | Customer support message operations |
| Shared auth include | `src/main/webapp/WEB-INF/auth.jsp` | JSP session and auth helper |
| Shared header | `src/main/webapp/WEB-INF/header.jsp` | Common navigation and layout header |
| Shared footer | `src/main/webapp/WEB-INF/footer.jsp` | Common page footer |
| Web config | `src/main/webapp/WEB-INF/web.xml` | Web application configuration |
| Main CSS | `src/main/webapp/assets/css/style.css` | Application styling |
| Main JS | `src/main/webapp/assets/js/main.js` | Frontend interactions |

## MVC Structure

### Model

Model classes represent application data:

- `src/main/java/com/medicare/model/User.java`
- `src/main/java/com/medicare/model/Medicine.java`

### DAO Layer

DAO classes handle database operations:

- `src/main/java/com/medicare/dao/UserDAO.java`
- `src/main/java/com/medicare/dao/MedicineDAO.java`
- `src/main/java/com/medicare/dao/CartOrderDAO.java`
- `src/main/java/com/medicare/dao/OrderIssueDAO.java`

### Controller Layer

Servlets handle requests, validation, session flow, and redirects:

- `src/main/java/com/medicare/servlet/auth/LoginServlet.java`
- `src/main/java/com/medicare/servlet/auth/RegisterServlet.java`
- `src/main/java/com/medicare/servlet/auth/LogoutServlet.java`
- `src/main/java/com/medicare/servlet/admin/PharmacistServlet.java`
- `src/main/java/com/medicare/servlet/admin/UserServlet.java`
- `src/main/java/com/medicare/servlet/admin/OrderIssueServlet.java`
- `src/main/java/com/medicare/servlet/pharmacist/MedicineServlet.java`
- `src/main/java/com/medicare/servlet/pharmacist/OrderStatusServlet.java`
- `src/main/java/com/medicare/servlet/user/CartServlet.java`
- `src/main/java/com/medicare/servlet/user/OrderIssueServlet.java`

### View Layer

JSP pages render the interface:

- `src/main/webapp/index.jsp`
- `src/main/webapp/login.jsp`
- `src/main/webapp/register.jsp`
- `src/main/webapp/admin/dashboard.jsp`
- `src/main/webapp/admin/manage-pharmacists.jsp`
- `src/main/webapp/admin/manage-users.jsp`
- `src/main/webapp/admin/orders.jsp`
- `src/main/webapp/admin/order-messages.jsp`
- `src/main/webapp/pharmacist/dashboard.jsp`
- `src/main/webapp/pharmacist/manage-medicines.jsp`
- `src/main/webapp/pharmacist/orders.jsp`
- `src/main/webapp/pharmacist/analytics.jsp`
- `src/main/webapp/user/dashboard.jsp`
- `src/main/webapp/user/medicines.jsp`
- `src/main/webapp/user/cart.jsp`
- `src/main/webapp/user/orders.jsp`

## Team Contributions

### Anuradha

Smart customer medicine ordering, cart, delivery selection, and order tracking.

- Landing page
- Customer medicine browsing
- Add to cart
- Cart quantity update
- Live subtotal and total calculation
- Order placement
- Delivery method selection
- Order tracking
- User order issue/message sending
- Customer order status sections

Branch:

```text
feature/anuradha-customer-ordering-delivery
```

### Damsi

Pharmacist inventory, order processing, and stock/sales analytics.

- Common UI theme
- Pharmacist dashboard
- Add, update, and delete medicines
- Upload medicine images
- Manage medicine stock
- Select transport methods
- View pharmacist-related orders
- Update order status
- Add expected delivery date/time
- Sales analytics and low-stock details

Branch:

```text
feature/damsi-pharmacist-inventory-analytics
```

### Supuni

Authentication, registration, session handling, and role-based access.

- Login page
- Register page
- User registration
- Pharmacist registration
- Password hashing
- Session handling
- Role-based redirection
- Unauthorized access prevention
- Logout system
- Pending pharmacist login blocking

Branch:

```text
feature/supuni-auth-role-access
```

### Pabasha

Admin control, pharmacist approval, and customer support management.

- Admin dashboard
- View and delete users
- View pharmacists
- Approve pending pharmacists
- Delete pharmacists
- View all orders
- View customer order messages
- Reply to customer messages
- Update message status
- Admin order and system monitoring

Branch:

```text
feature/pabasha-admin-approval-support
```

## Common Errors

### Database Connection Error

Check:

- MySQL server is running
- `online_medicine_db` was imported
- MySQL username and password in `DBConnection.java`
- MySQL port is correct, usually `3306`

### 404 Error

Check:

- Tomcat is using the correct WAR exploded artifact
- Application context is `/online_medicine_system`
- Tomcat version is 10.x

### Invalid Login

Check:

- SQL script was imported successfully
- Correct sample email is used
- Password is `123456`

### Servlet or Jakarta Error

This project uses Jakarta Servlet APIs. Use Apache Tomcat 10.x, not Tomcat 9.x.

## Repository Branches

- `main`
- `feature/anuradha-customer-ordering-delivery`
- `feature/damsi-pharmacist-inventory-analytics`
- `feature/supuni-auth-role-access`
- `feature/pabasha-admin-approval-support`

## Project Scope

This project was developed as a group academic web application using Java, JSP, Servlets, JDBC, MySQL, and MVC architecture. It focuses on medicine ordering, pharmacist approval, inventory management, order processing, delivery tracking, admin support, and role-based access control.

## License

This project is developed for academic purposes.
