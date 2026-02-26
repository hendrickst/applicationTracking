// ---------- Report Filter ----------

document.addEventListener("DOMContentLoaded", function () {
  const statusFilter = document.getElementById("statusFilter");
  const companyFilter = document.getElementById("companyFilter");
  const rows = document.querySelectorAll("#reportTable tbody tr");

  if (!statusFilter || !companyFilter) return;

  // Populate company dropdown dynamically
  const companies = new Set();

  rows.forEach(row => {
    const company = row.getAttribute("data-company");
    if (company) companies.add(company);
  });

  [...companies].sort().forEach(company => {
    const option = document.createElement("option");
    option.value = company;
    option.textContent = company;
    companyFilter.appendChild(option);
  });

  function applyFilters() {
    const selectedStatus = statusFilter.value;
    const selectedCompany = companyFilter.value;

    rows.forEach(row => {
      const rowStatus = row.getAttribute("data-status");
      const rowCompany = row.getAttribute("data-company");

      const statusMatch =
        selectedStatus === "All" || rowStatus === selectedStatus;

      const companyMatch =
        selectedCompany === "All" || rowCompany === selectedCompany;

      row.style.display = statusMatch && companyMatch ? "" : "none";
    });
  }

  statusFilter.addEventListener("change", applyFilters);
  companyFilter.addEventListener("change", applyFilters);
});