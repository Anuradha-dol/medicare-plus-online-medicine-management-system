function confirmDelete(){
    return confirm("Are you sure you want to delete this record?");
}

document.addEventListener("DOMContentLoaded", function () {
    function ensureToastStack() {
        var stack = document.querySelector(".toast-stack");
        if (!stack) {
            stack = document.createElement("div");
            stack.className = "toast-stack";
            stack.setAttribute("aria-live", "polite");
            stack.setAttribute("aria-atomic", "true");
            document.body.appendChild(stack);
        }
        return stack;
    }

    function showToast(type, message) {
        if (!message) return;

        var stack = ensureToastStack();
        var toast = document.createElement("div");
        toast.className = "toast " + type;

        var icon = document.createElement("span");
        icon.className = "toast-icon";
        icon.textContent = type === "success" ? "OK" : "!";

        var text = document.createElement("div");
        text.className = "toast-text";
        text.textContent = message;

        var close = document.createElement("button");
        close.className = "toast-close";
        close.type = "button";
        close.setAttribute("aria-label", "Close message");
        close.textContent = "x";

        function hideToast() {
            toast.classList.remove("show");
            window.setTimeout(function () {
                if (toast.parentNode) toast.parentNode.removeChild(toast);
            }, 220);
        }

        close.addEventListener("click", hideToast);
        toast.appendChild(icon);
        toast.appendChild(text);
        toast.appendChild(close);
        stack.appendChild(toast);

        window.requestAnimationFrame(function () {
            toast.classList.add("show");
        });
        window.setTimeout(hideToast, type === "error" ? 6200 : 4600);
    }

    function initToasts() {
        var source = document.getElementById("toastSource");
        if (!source) return;

        showToast("success", source.dataset.success || "");
        showToast("error", source.dataset.error || "");

        if ((source.dataset.success || source.dataset.error) && window.history && window.history.replaceState) {
            var cleanUrl = new URL(window.location.href);
            cleanUrl.searchParams.delete("success");
            cleanUrl.searchParams.delete("error");
            window.history.replaceState({}, document.title, cleanUrl.pathname + cleanUrl.search + cleanUrl.hash);
        }
    }

    initToasts();

    var roleSelect = document.getElementById("roleSelect");
    var pharmacistFields = document.getElementById("pharmacistFields");
    var pharmacyName = document.getElementById("pharmacyName");
    var pharmacyAddress = document.getElementById("pharmacyAddress");

    if (roleSelect && pharmacistFields) {
        function togglePharmacistFields() {
            var isPharmacist = roleSelect.value === "pharmacist";
            pharmacistFields.classList.toggle("hidden", !isPharmacist);
            if (pharmacyName) pharmacyName.required = isPharmacist;
            if (pharmacyAddress) pharmacyAddress.required = isPharmacist;
        }

        roleSelect.addEventListener("change", togglePharmacistFields);
        togglePharmacistFields();
    }

    function formatMoney(value) {
        var number = Number(value);
        if (Number.isNaN(number)) return "0.00";
        return number.toFixed(2);
    }

    document.querySelectorAll(".medicine-order-form").forEach(function (form) {
        var input = form.querySelector(".quantity-input");
        var total = form.querySelector(".line-total");
        var unitPrice = Number(form.dataset.unitPrice || 0);

        function updateMedicineTotal() {
            var qty = Number(input.value || 1);
            total.textContent = formatMoney(unitPrice * qty);
        }

        if (input && total) {
            input.addEventListener("input", updateMedicineTotal);
            input.addEventListener("change", updateMedicineTotal);
            updateMedicineTotal();
        }
    });

    function updateCartGrandTotal() {
        var grandTotal = 0;
        document.querySelectorAll(".cart-row-subtotal").forEach(function (subtotal) {
            grandTotal += Number(subtotal.dataset.value || subtotal.textContent || 0);
        });

        var output = document.getElementById("cartGrandTotal");
        if (output) output.textContent = formatMoney(grandTotal);
    }

    document.querySelectorAll(".cart-quantity-input").forEach(function (input) {
        var row = input.closest("tr");
        var subtotal = row ? row.querySelector(".cart-row-subtotal") : null;
        var unitPrice = Number(input.dataset.unitPrice || 0);

        function updateCartRowTotal() {
            var qty = Number(input.value || 1);
            var value = unitPrice * qty;
            if (subtotal) {
                subtotal.dataset.value = String(value);
                subtotal.textContent = formatMoney(value);
            }
            updateCartGrandTotal();
        }

        input.addEventListener("input", updateCartRowTotal);
        input.addEventListener("change", updateCartRowTotal);
        updateCartRowTotal();
    });

    function initOrderFilters() {
        var buttons = Array.prototype.slice.call(document.querySelectorAll("[data-order-filter]"));
        var sections = Array.prototype.slice.call(document.querySelectorAll("[data-order-section]"));
        if (!buttons.length || !sections.length) return;

        function applyFilter(filter) {
            sections.forEach(function (section) {
                var visible = filter === "all" || section.dataset.orderSection === filter;
                section.hidden = !visible;
            });

            buttons.forEach(function (button) {
                button.classList.toggle("active", button.dataset.orderFilter === filter);
            });
        }

        buttons.forEach(function (button) {
            button.addEventListener("click", function () {
                var filter = button.dataset.orderFilter || "all";
                applyFilter(filter);
            });
        });

        applyFilter("all");
    }

    initOrderFilters();
});
