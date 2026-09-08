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

            const root = xml.documentElement;
            const applications = Array.from(xml.getElementsByTagName("application"))
                .map(node => ({
                    applied: node.getAttribute("applied"),
                    status: node.getAttribute("status") || ""
                }))
                .filter(app => /^\d{4}-\d{2}-\d{2}$/.test(app.applied));

            const data = buildWeeklyData(applications);
            data.totalApplications = Number(root.getAttribute("total")) || applications.length;
            data.totalRejected = Number(root.getAttribute("rejected")) || 0;

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
    let cumulativeApplications = 0;
    let cumulativeRejected = 0;

    for (let week = new Date(minWeek); week <= maxWeek; week.setDate(week.getDate() + 7)) {
        const key = dateKey(week);
        const entry = weekly.get(key) || { week: key, applications: 0, rejected: 0 };

        cumulativeApplications += entry.applications;
        cumulativeRejected += entry.rejected;

        weeks.push({
            week: key,
            applications: entry.applications,
            rejected: entry.rejected,
            cumulativeApplications,
            cumulativeRejected
        });
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
    monday.setDate(monday.getDate() - (day === 0 ? 6 : day - 1));
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

    const width = 1000;
    const height = 500;
    const margin = { top: 45, right: 40, bottom: 90, left: 65 };
    const plotWidth = width - margin.left - margin.right;
    const plotHeight = height - margin.top - margin.bottom;
    const maxValue = Math.max(1, ...weeks.map(w => Math.max(w.cumulativeApplications, w.cumulativeRejected)));
    const yMax = Math.max(5, Math.ceil(maxValue / 5) * 5);

    const x = i => weeks.length === 1
        ? margin.left + plotWidth / 2
        : margin.left + (i / (weeks.length - 1)) * plotWidth;
    const y = value => margin.top + plotHeight - (value / yMax) * plotHeight;
    const linePath = key => weeks.map((w, i) =>
        `${i === 0 ? "M" : "L"} ${x(i).toFixed(1)} ${y(w[key]).toFixed(1)}`
    ).join(" ");

    const svg = `<svg xmlns="http://www.w3.org/2000/svg" class="weekly-svg" viewBox="0 0 ${width} ${height}" role="img" aria-labelledby="weekly-chart-title">
        <title id="weekly-chart-title">Cumulative weekly application and rejection trends</title>
        <text class="chart-title" x="${width / 2}" y="25" text-anchor="middle">Cumulative Application &amp; Rejection Trends</text>`;

    let svgMarkup = svg;

    for (let i = 0; i <= 5; i++) {
        const value = Math.round((yMax / 5) * i);
        const yy = y(value);
        svgMarkup += `<line class="chart-grid" x1="${margin.left}" y1="${yy}" x2="${width - margin.right}" y2="${yy}"/>`;
        svgMarkup += `<text class="chart-axis-label" x="${margin.left - 12}" y="${yy + 4}" text-anchor="end">${value}</text>`;
    }

    svgMarkup += `<line class="chart-axis" x1="${margin.left}" y1="${margin.top + plotHeight}" x2="${width - margin.right}" y2="${margin.top + plotHeight}"/>`;
    svgMarkup += `<text class="chart-y-title" transform="translate(18 ${margin.top + plotHeight / 2}) rotate(-90)" text-anchor="middle">Cumulative Applications</text>`;

    // Add vertical separators at the first week of each month.
    weeks.forEach((w, i) => {
        if (i === 0 || w.week.substring(0, 7) !== weeks[i - 1].week.substring(0, 7)) {
            svgMarkup += `<line class="chart-month-separator" x1="${x(i)}" y1="${margin.top}" x2="${x(i)}" y2="${margin.top + plotHeight}"/>`;
        }
    });

    svgMarkup += `<path class="chart-line applications-line" d="${linePath("cumulativeApplications")}"/>`;
    svgMarkup += `<path class="chart-line rejected-line" d="${linePath("cumulativeRejected")}"/>`;

    weeks.forEach((w, i) => {
        // Show one label per month, using the month/year of the first plotted week.
        const isFirstWeekOfMonth = i === 0 || w.week.substring(0, 7) !== weeks[i - 1].week.substring(0, 7);
        if (isFirstWeekOfMonth) {
            svgMarkup += `<text class="chart-x-label" x="${x(i)}" y="${height - 45}" text-anchor="start">${formatMonth(w.week)}</text>`;
        }
        svgMarkup += `<circle class="chart-point applications-point" cx="${x(i)}" cy="${y(w.cumulativeApplications)}" r="4"><title>${formatWeek(w.week)}: ${w.cumulativeApplications} cumulative applications</title></circle>`;
        svgMarkup += `<circle class="chart-point rejected-point" cx="${x(i)}" cy="${y(w.cumulativeRejected)}" r="4"><title>${formatWeek(w.week)}: ${w.cumulativeRejected} cumulative rejected</title></circle>`;
    });

    svgMarkup += `<g class="chart-legend">
        <line class="legend-line applications-line" x1="${margin.left}" y1="${height - 15}" x2="${margin.left + 30}" y2="${height - 15}"/>
        <circle class="applications-point" cx="${margin.left + 15}" cy="${height - 15}" r="4"/>
        <text x="${margin.left + 40}" y="${height - 11}">Cumulative applications</text>
        <line class="legend-line rejected-line" x1="${margin.left + 220}" y1="${height - 15}" x2="${margin.left + 250}" y2="${height - 15}"/>
        <circle class="rejected-point" cx="${margin.left + 235}" cy="${height - 15}" r="4"/>
        <text x="${margin.left + 260}" y="${height - 11}">Cumulative rejected</text>
    </g></svg>`;

    const svgDocument = new DOMParser().parseFromString(svgMarkup, "image/svg+xml");
    if (svgDocument.querySelector("parsererror")) {
        throw new Error("Unable to build weekly chart SVG");
    }

    container.replaceChildren(document.importNode(svgDocument.documentElement, true));
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
    return parseLocalDate(dateString).toLocaleDateString(undefined, {
        month: "short", day: "numeric"
    });
}

function formatMonth(dateString) {
    return parseLocalDate(dateString).toLocaleDateString(undefined, {
        month: "short", year: "numeric"
    });
}

function escapeHtml(value) {
    return String(value).replace(/[&<>"']/g, ch => ({
        "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;"
    }[ch]));
}
