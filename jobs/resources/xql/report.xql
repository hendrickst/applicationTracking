xquery version "3.1";

declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "html";
declare option output:media-type "text/html";
declare option output:indent "yes";

let $apps := collection("/db/jobs/applications")/job
let $today := current-date()

let $total := count($apps)
let $submitted := count($apps[status = "Submitted"])
let $interview := count($apps[status = "Interview"])
let $rejected := count($apps[status = "Rejected"])
let $interviewNotes := count($apps/notes/note[@type = "Interview"])

return
<html>
<head>
    <title>Job Applications Report</title>
    <link rel="stylesheet" type="text/css" href="../css/styles.css"/>
</head>
<body>

<div class="container">
    <div class="back-link">
        <a href="../../index.html">Back to Dashboard</a>
    </div>
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
            <div class="summary-label">Interview Status</div>
        </div>
        <div class="summary-card">
            <div class="summary-number">{$rejected}</div>
            <div class="summary-label">Rejected</div>
        </div>

        <div class="summary-card">
            <div class="summary-number" style="color: #10b981;">{$interviewNotes}</div>
            <div class="summary-label">Interviews</div>
        </div>
    </div>

    <div class="filter-bar">
        <div class="filter-group">
            <label for="statusFilter">Filter by Status</label>
            <select id="statusFilter">
                <option value="All">All</option>
                <option value="Submitted">Submitted</option>
                <option value="Interview">Interview</option>
                <option value="Rejected">Rejected</option>
            </select>
        </div>
            
        <div class="filter-group">
            <label for="companyFilter">Filter by Company</label>
            <select id="companyFilter">
                <option value="All">All</option>
            </select>
        </div>

        <div class="filter-group">
            <label for="noteTypeFilter">Filter by Latest Note Type</label>
            <select id="noteTypeFilter">
                <option value="All">All</option>
                <option value="Initial">Initial</option>
                <option value="Interview">Interview</option>
                <option value="Rejection">Rejection</option>
                <option value="Other">Other</option>
            </select>
        </div>
    </div>

    <div class="table-wrapper">
        <table class="report-table" id="reportTable">
            <thead>
                <tr>
                    <th>Job Title</th>
                    <th>Company</th>
                    <th>Date Applied</th>
                    <th>Days Open</th>
                    <th>Status</th>
                    <th>Latest Note</th> <th>URL</th>
                </tr>
            </thead>
            <tbody>
            {
                if (empty($apps)) then
                    <tr>
                        <td colspan="7" style="text-align:center; padding:20px;">No applications found.</td>
                    </tr>
                else
                    for $job in $apps
                    let $id := $job/@id/string()
                    let $title := $job/title/string()
                    let $company := $job/company/string()
                    let $appliedStr := $job/dates/@applied/string()
                    let $applied := try {
                                        if ($appliedStr) then xs:date($appliedStr) else ()
                                    } catch * {
                                        ()
                                    }
                    let $days :=    if (exists($applied)) then
                                        xs:integer(days-from-duration($today - $applied))
                                    else
                                        ""
                    let $status :=  if (normalize-space($job/status/string()) != "") then
                                        $job/status/string()
                                    else
                                        "Submitted"
                    let $url := $job/url/string()
                    
                    (: 2. EXTRACT LATEST NOTE & TYPE :)
                    let $latestNote := $job/notes/note[last()]
                    let $noteType := $latestNote/@type/string()
                    let $noteText := $latestNote/string()
                    
                    order by $applied descending
                    return
                        <tr data-status="{$status}" data-company="{$company}" data-note-type="{if ($noteType) then $noteType else 'Other'}">
                            <td>
                                <a class="job-link" href="../../update.html?record={$id}">
                                    {$title}
                                </a>
                            </td>
                            <td>{$company}</td>
                            <td>{$appliedStr}</td>
                            <td>{$days}</td>
                            <td class="status {$status}">
                                {$status}
                            </td>
                            
                            <td>
                                {
                                    if ($noteType or $noteText) then
                                        <span>
                                            <strong>[{if ($noteType) then $noteType else "Other"}]</strong> 
                                            {if ($noteText) then concat(" - ", $noteText) else ""}
                                        </span>
                                    else
                                        "-"
                                }
                            </td>
                            
                            <td>
                                {
                                    if ($url) then
                                        <a class="external-link" href="{$url}" target="_blank">View</a>
                                    else
                                        "-"
                                }
                            </td>
                        </tr>
            }
            </tbody>
        </table>
    </div>

</div>

<script type="text/javascript" src="../js/report.js"></script>

</body>
</html>
