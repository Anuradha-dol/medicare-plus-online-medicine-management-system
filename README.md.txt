# MediCare Plus – Online Medicine Management System

MediCare Plus is a Java-based web application developed for online medicine ordering and pharmacy management. The system allows customers to browse medicines, add medicines to cart, place orders, track delivery status, and send order-related issues to the admin. Pharmacists can manage medicines and process customer orders after admin approval, while the admin manages users, pharmacists, approvals, orders, and customer support messages.

## Project Type

Java JSP Servlet MVC Web Application

## Technologies Used

* Java
* JSP
* Servlet
* JDBC
* MySQL
* Apache Tomcat
* HTML
* CSS
* JavaScript
* Bootstrap
* Maven
* MVC Architecture

## System Roles

The system has three main user roles:

* Admin
* Pharmacist
* User / Customer

Each role has a separate dashboard and separate access permissions.

## Main Features

### Public Website

* Professional pharmacy-themed landing page
* Login page
* Sign-up page
* User and pharmacist registration
* Pharmacist registration with pharmacy name and pharmacy address
* Responsive user interface
* Toast and popup messages

### Admin Features

* Admin dashboard with analytics
* View registered users
* Delete users
* View registered pharmacists
* Approve pending pharmacist accounts
* Delete pharmacists
* View all customer orders
* View order status and transport method
* View customer order issues/messages
* Reply to customer messages
* Update message status as Open, In Review, Resolved, or Closed

### Pharmacist Features

* Pharmacist account approval flow
* Pending pharmacist cannot login before admin approval
* Add medicines
* Upload medicine images
* Update own medicines
* Delete own medicines
* Manage medicine stock
* Select available transport methods
* View orders related to own medicines only
* Update order status as Pending, Approved, Completed, or Cancelled
* Add expected delivery date/time when approving orders
* View sales analytics and low stock details

### User Features

* Register and login without admin approval
* Browse available medicines
* View medicine image, price, stock, category, and description
* Add medicines to cart
* Update cart quantity
* Remove cart items
* View live subtotal and total price
* Place medicine orders
* Select available transport method
* View order history
* Track orders under All, Pending, On The Way, Completed, and Cancelled
* Send order-related issues to admin
* View admin response under each order

## Order Flow

1. User browses medicines.
2. User adds medicines to cart.
3. User selects quantity and transport method.
4. User places the order.
5. Order status starts as Pending.
6. Pharmacist reviews and approves the order.
7. Pharmacist enters expected delivery date and time.
8. User sees the order as On The Way.
9. Pharmacist marks the order as Completed after delivery.
10. User can send an issue/message to admin if needed.

## MVC Architecture

The system follows the MVC architecture.

### Model

Model classes and DAO classes handle data and database operations.

Examples:

* User.java
* Medicine.java
* Order.java
* OrderIssue.java
* UserDAO.java
* MedicineDAO.java
* CartOrderDAO.java
* OrderIssueDAO.java

### View

JSP pages handle the user interface.

Examples:

* landing.jsp
* login.jsp
* register.jsp
* admin/dashboard.jsp
* pharmacist/dashboard.jsp
* user/dashboard.jsp
* user/cart.jsp
* user/orders.jsp

### Controller

Servlets handle requests, validations, sessions, and redirections.

Examples:

* LoginServlet.java
* RegisterServlet.java
* LogoutServlet.java
* MedicineServlet.java
* OrderStatusServlet.java
* CartServlet.java
* OrderIssueServlet.java

## Database Tables

Main database tables:

* users
* medicines
* cart
* orders
* order_items
* order_issues

## Team Member Contribution

### Anuradha

Smart Customer Medicine Ordering, Cart, Delivery Selection and Order Tracking Management

Responsibilities:

* Landing page
* Customer medicine browsing
* Add to cart
* Cart quantity update
* Live subtotal and total calculation
* Order placement
* Delivery method selection
* Order tracking
* User order issue/message sending
* Customer order status sections

Branch:

```bash
feature/anuradha-customer-ordering-delivery
```

### Damsi

Pharmacist Inventory, Order Processing and Sales Analytics Management

Responsibilities:

* Common UI theme
* Pharmacist dashboard
* Add medicines
* Upload medicine images
* Update medicines
* Delete medicines
* Manage medicine stock
* Select transport methods
* View pharmacist-related orders
* Update order status
* Add expected delivery date/time
* Sales analytics and low stock details

Branch:

```bash
feature/damsi-pharmacist-inventory-analytics
```

### Supuni

Authentication, Registration, Session Handling and Role-Based Access Management

Responsibilities:

* Login page
* Register page
* User registration
* Pharmacist registration
* Password hashing
* Session handling
* Role-based redirection
* Prevent unauthorized access
* Logout system
* Pending pharmacist login blocking

Branch:

```bash
feature/supuni-auth-role-access
```

### Pabasha

Admin Control, Pharmacist Approval and Customer Support Management

Responsibilities:

* Admin dashboard
* View users
* Delete users
* View pharmacists
* Approve pending pharmacists
* Delete pharmacists
* View all orders
* View customer order messages
* Reply to customer messages
* Update message status
* Admin order and system monitoring

Branch:

```bash
feature/pabasha-admin-approval-support
```

## How to Run the Project

1. Clone the repository.

```bash
git clone https://github.com/Anuradha-dol/medicare-plus-online-medicine-management-system.git
```

2. Open the project in an IDE such as IntelliJ IDEA, Eclipse, or NetBeans.

3. Configure Apache Tomcat server.

4. Create a MySQL database.

```sql
CREATE DATABASE medicare_plus_db;
```

5. Import the provided SQL file into MySQL.

6. Update database connection details in the database configuration file.

7. Build and run the project on Apache Tomcat.

8. Open the website in the browser.

```url
http://localhost:8080/medicare-plus-online-medicine-management-system
```

## Project Scope

This project was developed as a group academic web application using Java JSP, Servlets, JDBC, MySQL, and MVC architecture. It focuses on medicine ordering, pharmacist approval, inventory handling, order processing, delivery tracking, admin support, and role-based access control.

## Repository Branches

* main
* feature/anuradha-customer-ordering-delivery
* feature/damsi-pharmacist-inventory-analytics
* feature/supuni-auth-role-access
* feature/pabasha-admin-approval-support

## License

This project is developed for academic purposes.
