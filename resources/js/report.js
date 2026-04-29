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

  // Sort alphabetically
  const sortedCompanies = Array.from(companies).sort();

  sortedCompanies.forEach(company => {
    const option = document.createElement("option");
    option.value = company;
    option.textContent = company;
    select.appendChild(option);
  });
}

function filterCompany() {
  const selected = document.getElementById("companyFilter").value.toLowerCase();

  const table = document.getElementById("jobsTable");
  const rows = table.getElementsByTagName("tr");

  for (let i = 1; i < rows.length; i++) {
    const cells = rows[i].getElementsByTagName("td");

    if (cells.length > 0) {
      const companyCell = cells[0]; // adjust if needed
      const txtValue = companyCell.textContent || companyCell.innerText;

      if (!selected || txtValue.toLowerCase() === selected) {
        rows[i].style.display = "";
      } else {
        rows[i].style.display = "none";
      }
    }
  }
}