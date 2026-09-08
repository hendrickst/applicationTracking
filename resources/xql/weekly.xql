xquery version "3.1";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "json";
declare option output:media-type "application/json";

declare function local:weeks($start as xs:date, $end as xs:date) as xs:date* {
    if ($start gt $end) then ()
    else ($start, local:weeks($start + xs:dayTimeDuration("P7D"), $end))
};

let $apps := collection("/db/jobs/applications")/job
let $dated-apps := $apps[dates/@applied castable as xs:date]
let $min-date := if (exists($dated-apps)) then min($dated-apps/dates/@applied/xs:date(.)) else current-date()
let $max-date := if (exists($dated-apps)) then max($dated-apps/dates/@applied/xs:date(.)) else current-date()
let $min-week := $min-date - xs:dayTimeDuration(concat(day-of-week-from-date($min-date) - 1, "D"))
let $max-week := $max-date - xs:dayTimeDuration(concat(day-of-week-from-date($max-date) - 1, "D"))
let $weeks := local:weeks($min-week, $max-week)
let $data :=
    for $week in $weeks
    let $next-week := $week + xs:dayTimeDuration("P7D")
    let $week-apps := $dated-apps[dates/@applied/xs:date(.) ge $week and dates/@applied/xs:date(.) lt $next-week]
    return map {
        "week": string($week),
        "applications": count($week-apps),
        "rejected": count($week-apps[normalize-space(status) = "Rejected"])
    }
return map {
    "weeks": array { $data },
    "totalApplications": count($dated-apps),
    "totalRejected": count($dated-apps[normalize-space(status) = "Rejected"])
}