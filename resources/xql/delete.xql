xquery version "3.1";

import module namespace tsh="tsh" at "./config.xql";
import module namespace request="http://exist-db.org/xquery/request";

declare variable $record := request:get-parameter("record", "");
declare variable $type := request:get-parameter("type", "");

declare function local:delete() {
    let $safeRecord := matches($record, "^[A-Za-z0-9-]+$")
    let $safeType := $type = ("resume", "jobPosting")
    let $collection := $tsh:working || "/" || $record
    let $path := $collection || "/application.xml"
    let $job := if ($safeRecord and doc-available($path)) then doc($path)/job else ()
    let $document :=
        if ($type = "resume") then $job/documents/resume
        else if ($type = "jobPosting") then $job/documents/jobPosting
        else ()
    let $file := string($document/@file)
    return
        if (not($safeRecord) or not($safeType) or not($job) or not($document)) then
            (response:set-status-code(404),
             <result success="false" error="not-found"/>)
        else
            let $removeBinary :=
                if ($file and util:binary-doc-available($collection || "/" || $file))
                then xmldb:remove($collection, $file)
                else ()
            let $remaining :=
                if ($type = "resume") then $job/documents/jobPosting
                else $job/documents/resume
            let $newDocuments := <documents>{$remaining}</documents>
            let $replace := update replace $job/documents with $newDocuments
            return
                <result success="true" type="{$type}" fileRemoved="{exists($removeBinary)}"/>

};

system:as-user($tsh:adminUser, $tsh:adminPassword, local:delete())