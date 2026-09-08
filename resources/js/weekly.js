document.addEventListener("DOMContentLoaded", loadWeeklyReport);

function loadWeeklyReport() {
    fetch("./resources/xql/weekly.xql")
        .then(response => {
            if (!response.ok) throw new Error("Failed to load weekly report");
            return response.text();
        })
        .then(xmlText => {
            const xml = new DOMParser().parseFromString(xmlText, "application/xml");
            if (xml.querySelector("parsererror")) throw new Error("Invalid weekly report XML");

            const applications = Array.from(xml.getElementsByTagName("application"))
                .map(node => ({
                    applied: node.getAttribute("applied"),
                    status: node.getAttribute("status") || ""
                }))
                .filter(app => /^\d{4}-\d{2}-\d{2}$/.test(app.applied) && !Number.isNaN(parseLocalDate(app.applied).getTime()));

            const data = buildWeeklyData(applications);
            renderSummary(data);
            renderChart(data.weeks);
            renderTable(data.weeks);
        })
        .catch(err => {
            document.getElementById("weekly-chart").innerHTML =
                `<div class="error">Error loading weekly report: ${escapeHtml(err.message)}</div>`;
            console.error(err);
        });
}

function buildWeeklyData(applications) {
    if (!applications.length) return { weeks: [], totalApplications: 0, totalRejected: 0 };

    const weekly = new Map();
    let minWeek = null;
    let maxWeek = null;

    applications.forEach(app => {
        const date = parseLocalDate(app.applied);
        const week = getMonday(date);
        const key = dateKey(week);

        if (!weekly.has(key)) weekly.set(key, { week: key, applications: 0, rejected: 0 });

        const entry = weekly.get(key);
        entry.applications += 1;
        if (app.status.trim() === "Rejected") entry.rejected += 1;

        if (!minWeek || week < minWeek) minWeek = week;
        if (!maxWeek || week > maxWeek) maxWeek = week;
    });

    const weeks = [];
    for (let week = new Date(minWeek); week <= maxWeek; week.setDate(week.getDate() + 7)) {
        const key = dateKey(week);
        weeks.push(weekly.get(key) || { week: key, applications: 0, rejected: 0 });
    }

    return {
        weeks,
        totalApplications: applications.length,
        totalRejected: applications.filter(app => app.status.trim() === "Rejected").length
    };
}

function parseLocalDate(dateString) {
    const [year, month, day] = dateString.split("-").map(Number);
    return new Date(year, month - 1, day);
}

function getMonday(date) {
    const monday = new Date(date.getFullYear(), date.getMonth(), date.getDate());
    const day = monday.getDay();
    const daysSinceMonday = day === 0 ? 6 : day - 1;
    monday.setDate(monday.getDate() - daysSinceMonday);
    return monday;
}

function dateKey(date) {
    return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, "0")}-${String(date.getDate()).padStart(2, "0")}`;
}

function renderSummary(data) {
    document.getElementById("weekly-summary").innerHTML = `
        <div class="summary-card">
            <div class="summary-number">${data.totalApplications || 0}</div>
            <div class="summary-label">Applications</div>
        </div>
        <div class="summary-card">
            <div class="summary-number">${data.totalRejected || 0}</div>
            <div class="summary-label">Rejected</div>
        </div>`;
}

function renderChart(weeks) {
    const container = document.getElementById("weekly-chart");
    if (!weeks.length) {
        container.innerHTML = '<div class="loading">No dated applications found.</div>';
        return;
    }

    const width = 900;
    const height = 430;
    const margin = { top: 30, right: 30, bottom: 70, left: 55 };
    const plotWidth = width - margin.left - margin.right;
    const plotHeight = height - margin.top - margin.bottom;
    const maxValue = Math.max(1, ...weeks.map(w => Math.max(Number(w.applications), Number(w.rejected))));
    const yMax = Math.ceil(maxValue / 5) * 5;

    const x = i => weeks.length === 1 ? margin.left + plotWidth / 2 : margin.left + (i / (weeks.length - 1)) * plotWidth;
    const y = value => margin.top + plotHeight - (value / yMax) * plotHeight;
    const linePath = key => weeks.map((w, i) => `${i === 0 ? "M" : "L"} ${x(i).toFixed(1)} ${y(Number(w[key])).toFixed(1)}`).join(" ");

    let svg = `<svg class="weekly-svg" viewBox="0 0 ${width} ${height}" role="img" aria-labelledby="weekly-chart-title">
        <title id="weekly-chart-title">Weekly applications and rejected applications</title>`;

    for (let i = 0; i <= 5; i++) {
        const value = Math.round((yMax / 5) * i);
        const yy = y(value);
        svg += `<line class="chart-grid" x1="${margin.left}" y1="${yy}" x2="${width - margin.right}" y2="${yy}"/>`;
        svg += `<text class="chart-axis-label" x="${margin.left - 10}" y="${yy + 4}" text-anchor="end">${value}</text>`;
    }

    svg += `<line class="chart-axis" x1="${margin.left}" y1="${margin.top + plotHeight}" x2="${width - margin.right}" y2="${margin.top + plotHeight}"/>`;
    svg += `<path class="chart-line applications-line" d="${linePath("applications")}"/>`;
    svg += `<path class="chart-line rejected-line" d="${linePath("rejected")}"/>`;

    weeks.forEach((w, i) => {
        const labelEvery = Math.max(1, Math.ceil(weeks.length / 12));
        if (i % labelEvery === 0 || i === weeks.length - 1) {
            svg += `<text class="chart-x-label" x="${x(i)}" y="${height - 35}" text-anchor="middle">${formatWeek(w.week)}</text>`;
        }
        svg += `<circle class="chart-point applications-point" cx="${x(i)}" cy="${y(Number(w.applications))}" r="3.5"><title>${formatWeek(w.week)}: ${w.applications} applications</title></circle>`;
        svg += `<circle class="chart-point rejected-point" cx="${x(i)}" cy="${y(Number(w.rejected))}" r="3.5"><title>${formatWeek(w.week)}: ${w.rejected} rejected</title></circle>`;
    });

    svg += `<g class="chart-legend">
        <line class="legend-line applications-line" x1="${margin.left}" y1="${height - 12}" x2="${margin.left + 25}" y2="${height - 12}"/>
        <text x="${margin.left + 32}" y="${height - 8}">Applications</text>
        <line class="legend-line rejected-line" x1="${margin.left + 150}" y1="${height - 12}" x2="${margin.left + 175}" y2="${height - 12}"/>
        <text x="${margin.left + 182}" y="${height - 8}">Rejected</text>
    </g></svg>`;

    container.innerHTML = svg;
}

function renderTable(weeks) {
    const rows = weeks.slice().reverse().map(w => `
        <tr>
            <td>${formatWeek(w.week)}</td>
            <td>${w.applications}</td>
            <td class="status Rejected">${w.rejected}</td>
        </tr>`).join("");

    document.getElementById("weekly-table").innerHTML = `
        <table class="report-table">
            <thead><tr><th>Week</th><th>Applications</th><th>Rejected</th></tr></thead>
            <tbody>${rows}</tbody>
        </table>`;
}

function formatWeek(dateString) {
    return parseLocalDate(dateString).toLocaleDateString(undefined, { month: "short", day: "numeric", year: "numeric" });
}

function escapeHtml(value) {
    return String(value).replace(/[&<>"']/g, ch => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[ch]));
}
