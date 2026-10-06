xquery version "3.1";
import module namespace xmldb="http://exist-db.org/xquery/xmldb";

declare variable $base := "/db/jobs";
declare variable $legacy := $base || "/applications";

(: Recover/migrate the legacy flat collection if the package install hook did not run. :)
let $_migration :=
    if (xmldb:collection-available($legacy)) then
        (
            for $name in xmldb:get-child-resources($legacy)
            where ends-with($name, ".xml")
            let $id := replace($name, "\\.xml$", "")
            let $c := $base || "/" || $id
            let $_c := if (xmldb:collection-available($c)) then () else xmldb:create-collection($base, $id)
            let $_x := if (not(doc-available($c || "/" || $name))) then xmldb:copy-resource($legacy, $name, $c, $name) else ()
            return (),
            if (count(xmldb:get-child-resources($legacy)) = 0) then xmldb:remove($legacy) else ()
        )
    else ()

let $apps :=
    for $id in xmldb:get-child-collections($base)
    let $j := doc($base || "/" || $id || "/" || $id || ".xml")
    where exists($j/job)
    return $j/job

let $total := count($apps)
let $submitted := count($apps[status = "Submitted"])
let $interview := count($apps[status = "Interview"])
let $rejected := count($apps[status = "Rejected"])

return
<div class="container">
    <div class="page-nav">
        <a href="./weekly.html">View Weekly Trends →</a>
    </div>
    <h1>Job Applications</h1>
    <p class="sub">Overview of all submitted positions.</p>
    <div class="summary-grid">
        <div class="summary-card"><div class="summary-number">{$total}</div><div class="summary-label">Total</div></div>
        <div class="summary-card"><div class="summary-number">{$submitted}</div><div class="summary-label">Submitted</div></div>
        <div class="summary-card"><div class="summary-number">{$interview}</div><div class="summary-label">Interview</div></div>
        <div class="summary-card"><div class="summary-number">{$rejected}</div><div class="summary-label">Rejected</div></div>
    </div>
    <div class="filter-bar">
        <label for="companyFilter">Filter by Company:</label>
        <select id="companyFilter" onchange="filterCompany()"><option value="">All Companies</option></select>
    </div>
    <table class="report-table" id="jobsTable">
        <thead><tr><th>Company</th><th>Title</th><th>Status</th><th>Applied</th></tr></thead>
        <tbody>{
            for $j in $apps
            let $id := string($j/@id)
            let $s := normalize-space($j/status)
            order by $j/dates/@applied descending
            return <tr class="{if($s = "Rejected") then "row-rejected" else if($s = "Interview") then "row-interview" else ""}">
                <td>{$j/company}</td>
                <td><a class="job-link" href="./update.html?record={$id}">{$j/title}</a></td>
                <td class="status {$s}">{$s}</td>
                <td>{$j/dates/@applied}</td>
            </tr>
        }</tbody>
    </table>
</div>