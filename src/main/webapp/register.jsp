<%@ include file="WEB-INF/header.jsp" %>

<section class="auth-page auth-register">
    <div class="auth-visual">
        <span class="eyebrow">Join MediCare Plus</span>
        <h1>Create your medical ordering account</h1>
        <p>Customers can order immediately. Pharmacists register their pharmacy details and wait for admin approval before login.</p>
        <div class="auth-benefits">
            <div><strong>Customers</strong><small>Browse, cart, and order medicines</small></div>
            <div><strong>Pharmacists</strong><small>Manage stock after admin approval</small></div>
            <div><strong>Admins</strong><small>Review accounts and monitor orders</small></div>
        </div>
    </div>

    <div class="auth-panel">
        <div class="auth-card-pro register-card">
            <span class="auth-kicker">New Account</span>
            <h2>Sign up</h2>
            <form action="register" method="post">
                <label>Register As</label>
                <select name="role" id="roleSelect" required>
                    <option value="user">User</option>
                    <option value="pharmacist">Pharmacist</option>
                </select>

                <div class="form-grid-2">
                    <div>
                        <label>Name</label>
                        <input type="text" name="name" placeholder="Full name" required>
                    </div>
                    <div>
                        <label>Email</label>
                        <input type="email" name="email" placeholder="Email address" required>
                    </div>
                </div>

                <div class="form-grid-2">
                    <div>
                        <label>Phone</label>
                        <input type="text" name="phone" placeholder="Phone number">
                    </div>
                    <div>
                        <label>Password</label>
                        <input type="password" name="password" placeholder="Create password" required>
                    </div>
                </div>

                <label>Address</label>
                <textarea name="address" placeholder="Your address"></textarea>

                <div id="pharmacistFields" class="hidden pharmacy-fields">
                    <label>Pharmacy Name</label>
                    <input type="text" name="pharmacyName" id="pharmacyName" placeholder="Registered pharmacy name">
                    <label>Pharmacy Address</label>
                    <textarea name="pharmacyAddress" id="pharmacyAddress" placeholder="Pharmacy location"></textarea>
                </div>

                <button class="success full-btn" type="submit">Create Account</button>
            </form>
            <div class="auth-switch">
                <span>Already registered?</span>
                <a href="login.jsp">Back to login</a>
            </div>
        </div>
    </div>
</section>

<%@ include file="WEB-INF/footer.jsp" %>
