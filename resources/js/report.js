let interviewFilterActive = false;

document.addEventListener("DOMContentLoaded", () => {
    loadReport();
});

function loadReport() {
    fetch("./resources/xql/report.xql")
        .then(response => {
            if (!response.ok) {
                throw new Error("Failed to load report");
            }
            return response.text();
        })
        .then(html => {
            document.getElementById("report-container").innerHTML = html;
            populateCompanyFilter();
        })
        .catch(err => {
            document.getElementById("report-container").innerHTML =
                `<div class="error">Error loading report: ${err.message}</div>`;
            console.error(err);
        });
}

function populateCompanyFilter() {
  const table = document.getElementById("jobsTable");
  const rows = table.getElementsByTagName("tr");

  const companies = new Set();

  for (let i = 1; i < rows.length; i++) { // skip header
    const cells = rows[i].getElementsByTagName("td");

    if (cells.length > 0) {
      const company = (cells[0].textContent || cells[0].innerText).trim();
      if (company) {
        companies.add(company);
      }
    }
  }

  const select = document.getElementById("companyFilter");

  // Clear existing (except "All")
  select.length = 1;

  // Sort alphabetically, ignoring case.
  const sortedCompanies = Array.from(companies).sort((a, b) =>
    a.localeCompare(b, undefined, { sensitivity: "base" })
  );

  sortedCompanies.forEach(company => {
    const option = document.createElement("option");
    option.value = company;
    option.textContent = company;
    select.appendChild(option);
  });
}

function filterCompany() {
  applyFilters();
}

function toggleInterviewFilter() {
  interviewFilterActive = !interviewFilterActive;
  const toggle = document.getElementById("interviewFilterToggle");
  if (toggle) {
    toggle.setAttribute("aria-pressed", String(interviewFilterActive));
    const label = toggle.querySelector(".summary-label");
    if (label) label.textContent = interviewFilterActive
      ? "Interview · click to show all"
      : "Interview · click to filter";
  }
  applyFilters();
}

function applyFilters() {
  const selected = (document.getElementById("companyFilter")?.value || "").toLowerCase();
  const table = document.getElementById("jobsTable");
  if (!table) return;
  const rows = table.querySelectorAll("tbody tr");

  rows.forEach(row => {
    const cells = row.getElementsByTagName("td");
    const company = (cells[0]?.textContent || "").trim().toLowerCase();
    const status = (cells[2]?.textContent || "").trim();
    const matchesCompany = !selected || company === selected;
    const matchesInterview = !interviewFilterActive || status === "Interview";
    row.style.display = matchesCompany && matchesInterview ? "" : "none";
  });
}