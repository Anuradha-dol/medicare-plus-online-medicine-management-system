<%@ include file="WEB-INF/header.jsp" %>

<section class="landing-hero">
    <div class="hero-content">
        <span class="eyebrow">Online Medicine Ordering System</span>
        <h1>Your Health,<br>Our <span>Priority</span></h1>
        <p>Order genuine medicines online from trusted pharmacists. Fast ordering, secure checkout, and pharmacist-managed stock in one simple system.</p>
        <div class="hero-actions">
            <a class="btn success" href="register.jsp">Browse Medicines</a>
            <a class="btn ghost" href="#how">Learn More</a>
        </div>
    </div>
</section>

<section id="medicines" class="feature-strip">
    <div class="feature-item">
        <span class="feature-icon green">G</span>
        <div><strong>100% Genuine</strong><small>Authentic medicines</small></div>
    </div>
    <div class="feature-item">
        <span class="feature-icon blue">D</span>
        <div><strong>Fast Delivery</strong><small>On-time ordering flow</small></div>
    </div>
    <div class="feature-item">
        <span class="feature-icon violet">S</span>
        <div><strong>Secure Payment</strong><small>Safe checkout process</small></div>
    </div>
    <div class="feature-item">
        <span class="feature-icon orange">H</span>
        <div><strong>24/7 Support</strong><small>Help when you need it</small></div>
    </div>
</section>

<section id="about" class="landing-section three-column">
    <div class="intro-panel">
        <h2>Welcome to <span>MediCare Plus</span></h2>
        <p>MediCare Plus connects customers with registered pharmacists for safe medicine browsing, ordering, and stock management.</p>
        <div class="mini-stats">
            <div><strong>1000+</strong><small>Happy customers</small></div>
            <div><strong>5000+</strong><small>Medicines</small></div>
            <div><strong>200+</strong><small>Pharmacies</small></div>
        </div>
    </div>

    <div id="roles" class="role-panel">
        <h2>Who Can Use Our System</h2>
        <div class="role-cards">
            <div class="mini-card">
                <span class="round-icon green">U</span>
                <h3>For Customers</h3>
                <p>Browse medicines, place orders, and track order status easily.</p>
            </div>
            <div class="mini-card">
                <span class="round-icon blue">P</span>
                <h3>For Pharmacists</h3>
                <p>Manage medicines, stock, and customer orders efficiently.</p>
            </div>
            <div class="mini-card">
                <span class="round-icon violet">A</span>
                <h3>For Admin</h3>
                <p>Approve pharmacists, manage accounts, and monitor the system.</p>
            </div>
        </div>
    </div>

    <div id="how" class="steps-panel">
        <h2>How It Works</h2>
        <div class="step-item"><span class="step-dot green">1</span><div><strong>Search Medicine</strong><small>Find available medicines.</small></div></div>
        <div class="step-item"><span class="step-dot blue">2</span><div><strong>Place Your Order</strong><small>Add to cart and order securely.</small></div></div>
        <div class="step-item"><span class="step-dot orange">3</span><div><strong>Pharmacist Handles It</strong><small>Approved pharmacists manage your order.</small></div></div>
    </div>
</section>

<section class="landing-footer">
    <span>(c) 2026 MediCare Plus. All rights reserved.</span>
    <span>Privacy Policy | Terms & Conditions | Refund Policy</span>
</section>

<%@ include file="WEB-INF/footer.jsp" %>
