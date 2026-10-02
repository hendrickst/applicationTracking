xquery version "3.1";
import module namespace tsh="tsh" at "./config.xql";
import module namespace request="http://exist-db.org/xquery/request";

declare variable $record := request:get-parameter("record", "");
declare variable $type := request:get-parameter("type", "");

declare function local:document-node($job, $type as xs:string) as element()? {
    if ($type = "resume") then $job/documents/resume
    else if ($type = "jobPosting") then $job/documents/jobPosting
    else ()
};

declare function local:delete() {
    let $safeRecord := matches($record, "^[A-Za-z0-9-]+$")
    let $safeType := $type = ("resume", "jobPosting")
    let $path := $tsh:working || "/" || $record || "/application.xml"
    let $job := if ($safeRecord and doc-available($path)) then doc($path)/job else ()
    let $document := local:document-node($job, $type)
    let $file := string($document/@file)
    let $collection := $tsh:working || "/" || $record
    let $binaryPath := $collection || "/" || $file
    return
        if (not($safeRecord) or not($safeType) or not($job) or not($document)) then
            (response:set-status-code(404), <result success="false" error="not-found"/>)
        else
            let $removeBinary :=
                if ($file and util:binary-doc-available($binaryPath))
                then xmldb:remove($collection, $file)
                else ()
            let $removeNode := update delete $document
            return <result success="true" type="{$type}"/>
};

system:as-user($tsh:adminUser, $tsh:adminPassword, local:delete())
