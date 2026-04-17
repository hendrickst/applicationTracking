xquery version "3.1";

let $apps := collection("/db/jobs/applications")/job

let $total := count($apps)
let $submitted := count($apps[status = "Submitted"])
let $interview := count($apps[status = "Interview"])
let $rejected := count($apps[status = "Rejected"])
let $interviewNotes := count($apps/notes/note[@type = "Interview"])

return
<div class="container">

    <h1>Job Applications</h1>
    <p class="sub">Overview of all submitted positions.</p>

    <div class="summary-grid">
        <div class="summary-card">
            <div class="summary-number">{$total}</div>
            <div class="summary-label">Total</div>
        </div>
        <div class="summary-card">
            <div class="summary-number">{$submitted}</div>
            <div class="summary-label">Submitted</div>
        </div>
        <div class="summary-card">
            <div class="summary-number">{$interview}</div>
            <div class="summary-label">Interview</div>
        </div>
        <div class="summary-card">
            <div class="summary-number">{$rejected}</div>
            <div class="summary-label">Rejected</div>
        </div>
        <div class="summary-card">
            <div class="summary-number">{$interviewNotes}</div>
            <div class="summary-label">Interview Notes</div>
        </div>
    </div>

    <table class="report-table">
        <thead>
            <tr>
                <th>Company</th>
                <th>Title</th>
                <th>Status</th>
                <th>Applied</th>
            </tr>
        </thead>
        <tbody>
        {
            for $job in $apps
            let $id := $job/@id
            let $status := normalize-space($job/status/text())
            let $rowClass :=
                if ($status = "Rejected") then "row-rejected"
                else if ($status = "Interview") then "row-interview"
                else ""
            order by $job/dates/@applied descending
            return
                <tr class="{$rowClass}">
                    <td>{$job/company/text()}</td>
                    <td>
                        <a href="./update.html?record={$id}">
                            {$job/title/text()}
                        </a>
                    </td>
                    <td class="status {$status}">{$status}</td>
                    <td>{$job/dates/@applied/string()}</td>
                </tr>
        }
        </tbody>
    </table>

</div>