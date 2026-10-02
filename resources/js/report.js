document.addEventListener("DOMContentLoaded", loadReport);

async function loadReport() {
    const container = document.getElementById("report-container");

    try {
        const response = await fetch("./resources/xql/report.xql", {
            cache: "no-store"
        });

        const body = await response.text();

        if (!response.ok) {
            throw new Error(`Report request failed (${response.status} ${response.statusText})${body ? ": " + body : ""}`);
        }

        if (!body.trim()) {
            throw new Error("Report query returned an empty response.");
        }

        // The XQuery endpoint returns XHTML. Parse it explicitly rather than
        // assigning the response directly to innerHTML; this avoids browser
        // differences when eXist serializes the result as XML/XHTML.
        const parsed = new DOMParser().parseFromString(body, "text/html");
        const report = parsed.querySelector(".container");

        if (!report) {
            throw new Error("Report query returned no report container.");
        }

        container.replaceChildren(...Array.from(report.childNodes).map(node =>
            document.importNode(node, true)
        ));

        populateCompanyFilter();
    } catch (err) {
        console.error("Job application report error:", err);
        container.innerHTML =
            `<div class="error"><strong>Error loading report.</strong><br/>${escapeHtml(err.message)}</div>`;
    }
}

function populateCompanyFilter() {
    const table = document.getElementById("jobsTable");
    if (!table) return;

    const rows = table.getElementsByTagName("tr");
    const companies = new Set();

    for (let i = 1; i < rows.length; i++) {
        const cells = rows[i].getElementsByTagName("td");

        if (cells.length > 0) {
            const company = (cells[0].textContent || cells[0].innerText).trim();
            if (company) companies.add(company);
        }
    }

    const select = document.getElementById("companyFilter");
    if (!select) return;

    select.length = 1;

    Array.from(companies)
        .sort((a, b) => a.localeCompare(b, undefined, { sensitivity: "base" }))
        .forEach(company => {
            const option = document.createElement("option");
            option.value = company;
            option.textContent = company;
            select.appendChild(option);
        });
}

function filterCompany() {
    const select = document.getElementById("companyFilter");
    const table = document.getElementById("jobsTable");
    if (!select || !table) return;

    const selected = select.value.toLowerCase();
    const rows = table.getElementsByTagName("tr");

    for (let i = 1; i < rows.length; i++) {
        const cells = rows[i].getElementsByTagName("td");

        if (cells.length > 0) {
            const company = (cells[0].textContent || cells[0].innerText).trim();
            rows[i].style.display =
                !selected || company.toLowerCase() === selected ? "" : "none";
        }
    }
}

function escapeHtml(value) {
    return String(value).replace(/[&<>"']/g, ch => ({
        "&": "&amp;",
        "<": "&lt;",
        ">": "&gt;",
        '"': "&quot;",
        "'": "&#39;"
    }[ch]));
}