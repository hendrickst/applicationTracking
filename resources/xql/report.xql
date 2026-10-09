xquery version "3.1";
import module namespace xmldb="http://exist-db.org/xquery/xmldb";

declare variable $base := "/db/jobs";
declare variable $legacy := $base || "/applications";

declare function local:copy-resources($source as xs:string, $target as xs:string) {
  for $name in xmldb:get-child-resources($source)
  return
    if ($name = xmldb:get-child-resources($target)) then ()
    else xmldb:copy-resource($source, $name, $target, $name)
};

declare function local:migrate-collection($source as xs:string, $id as xs:string) {
  let $target := $base || "/" || $id
  let $_create := if (xmldb:collection-available($target)) then () else xmldb:create-collection($base, $id)
  let $_copy := local:copy-resources($source, $target)
  let $_remove := if (xmldb:get-child-resources($source) = ()) then xmldb:remove($source) else ()
  return ()
};

declare function local:migrate-resource($source as xs:string, $name as xs:string) {
  let $id := replace($name, "\.xml$", "")
  let $target := $base || "/" || $id
  let $_create := if (xmldb:collection-available($target)) then () else xmldb:create-collection($base, $id)
  let $_copy := if ($name = xmldb:get-child-resources($target)) then () else xmldb:copy-resource($source, $name, $target, $name)
  return ()
};

(: Recover/migrate legacy layouts if the package install hook did not run. :)
let $_legacy :=
  if (xmldb:collection-available($legacy)) then
    (
      for $name in xmldb:get-child-resources($legacy)
      where ends-with($name, ".xml")
      let $id := replace($name, "\.xml$", "")
      return local:migrate-resource($legacy, $name),
      if (xmldb:get-child-resources($legacy) = ()) then xmldb:remove($legacy) else ()
    )
  else ()

(: Fix collections accidentally named <UUID>.xml. :)
let $_incorrect :=
  for $name in xmldb:get-child-collections($base)
  where ends-with($name, ".xml")
  let $id := replace($name, "\.xml$", "")
  return local:migrate-collection($base || "/" || $name, $id)

(: Handle direct XML resources in /db/jobs as well. :)
let $_direct :=
  for $name in xmldb:get-child-resources($base)
  where ends-with($name, ".xml")
  let $id := replace($name, "\.xml$", "")
  let $target := $base || "/" || $id
  let $_create := if (xmldb:collection-available($target)) then () else xmldb:create-collection($base, $id)
  let $_copy := if ($name = xmldb:get-child-resources($target)) then () else xmldb:copy-resource($base, $name, $target, $name)
  let $_remove := xmldb:remove($base, $name)
  return ()

let $apps :=
    for $id in xmldb:get-child-collections($base)
    where not(ends-with($id, ".xml"))
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
        <thead><tr><th>Company</th><th>Title</th><th>Status</th><th>Applied</th><th>AI Chat</th></tr></thead>
        <tbody>{
            for $j in $apps
            let $id := string($j/@id)
            let $s := normalize-space($j/status/text())
            order by $j/dates/@applied descending
            return <tr class="{if($s = "Rejected") then "row-rejected" else if($s = "Interview") then "row-interview" else ""}">
                <td>{$j/company/text()}</td>
                <td><a class="job-link" href="./update.html?record={$id}">{$j/title/text()}</a></td>
                <td class="status {$s}">{$s}</td>
                <td>{$j/dates/@applied/string()}</td>
                <td><a class="btn" href="./chat.html?record={$id}">Open Chat</a></td>
            </tr>
        }</tbody>
    </table>
</div>
