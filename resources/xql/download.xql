xquery version "3.1";
import module namespace tsh="tsh" at "./config.xql";
import module namespace request="http://exist-db.org/xquery/request";

declare variable $record := req:parameter("record");
declare variable $type := req:parameter("type");

declare function local:document-node($job, $type as xs:string) as element()? {
    if ($type = "resume") then $job/documents/resume
    else if ($type = "jobPosting") then $job/documents/jobPosting
    else ()
};

let $safeRecord := matches($record, "^[A-Za-z0-9-]+$")
let $safeType := $type = ("resume", "jobPosting")
let $path := $tsh:working || "/" || $record || "/application.xml"
let $job := if ($safeRecord and doc-available($path)) then doc($path)/job else ()
let $document := local:document-node($job, $type)
let $file := string($document/@file)
let $mime := string($document/@type)
let $name := string($document/@originalName)
let $binaryPath := $tsh:working || "/" || $record || "/" || $file

return
    if (not($safeRecord) or not($safeType) or not($job) or not($file) or not(util:binary-doc-available($binaryPath))) then
        response:set-status-code(404)
    else
        response:stream-binary(
            util:binary-doc($binaryPath),
            if ($mime) then $mime else "application/octet-stream",
            if ($name) then $name else $file
        )