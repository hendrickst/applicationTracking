// ---------- Report Filter ----------

document.addEventListener("DOMContentLoaded", function () {
  const statusFilter = document.getElementById("statusFilter");
  const companyFilter = document.getElementById("companyFilter");
  const noteTypeFilter = document.getElementById("noteTypeFilter"); // <-- Added
  const rows = document.querySelectorAll("#reportTable tbody tr");

  if (!statusFilter || !companyFilter || !noteTypeFilter) return;

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
    const selectedNoteType = noteTypeFilter.value; // <-- Added

    rows.forEach(row => {
      const rowStatus = row.getAttribute("data-status");
      const rowCompany = row.getAttribute("data-company");
      const rowNoteType = row.getAttribute("data-note-type"); // <-- Added

      const statusMatch =
        selectedStatus === "All" || rowStatus === selectedStatus;

      const companyMatch =
        selectedCompany === "All" || rowCompany === selectedCompany;

      const noteTypeMatch =
        selectedNoteType === "All" || rowNoteType === selectedNoteType; // <-- Added

      // Display row only if it matches all 3 criteria!
      row.style.display = statusMatch && companyMatch && noteTypeMatch ? "" : "none";
    });
  }

  statusFilter.addEventListener("change", applyFilters);
  companyFilter.addEventListener("change", applyFilters);
  noteTypeFilter.addEventListener("change", applyFilters); // <-- Added
});
