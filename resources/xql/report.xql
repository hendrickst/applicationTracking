xquery version "3.1";

import module namespace xmldb="http://exist-db.org/xquery/xmldb";

(: Return only application.xml documents directly stored in each collection.
   collection() can include descendant collections in eXist-db, so recursive
   collection() traversal would count the same application more than once. :)
declare function local:jobs($collection as xs:string) as element(job)* {
    let $here :=
        for $resource in xmldb:get-child-resources($collection)[. = "application.xml"]
        return doc(concat($collection, "/", $resource))/job
    let $children := xmldb:get-child-collections($collection)
    return (
        $here,
        for $child in $children
        let $childPath :=
            if (starts-with($child, "/")) then $child
            else concat($collection, "/", $child)
        return local:jobs($childPath)
    )
};

let $apps := local:jobs("/db/jobs")

let $total := count($apps)
let $submitted := count($apps[normalize-space(status) = "Submitted"])
let $interview := count($apps[normalize-space(status) = "Interview"])
let $rejected := count($apps[normalize-space(status) = "Rejected"])
let $interviewNotes := count($apps/notes/note[@type = "Interview"])

return
<div class="container">

    <div class="page-nav">
        <a href="./weekly.html">View Weekly Trends →</a>
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
    
    <div class="filter-bar">
        <label for="companyFilter">Filter by Company:</label>
        <select id="companyFilter" onchange="filterCompany()">
            <option value="">All Companies</option>
        </select>
    </div>

    <table class="report-table" id="jobsTable">
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