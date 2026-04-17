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
        })
        .catch(err => {
            document.getElementById("report-container").innerHTML =
                `<div class="error">Error loading report: ${err.message}</div>`;
            console.error(err);
        });
}