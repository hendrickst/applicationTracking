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
        if (not($safeRecord)) then
            (response:set-status-code(400),
             <result success="false" error="invalid-record"/>)
        else if (not($safeType)) then
            (response:set-status-code(400),
             <result success="false" error="invalid-type"/>)
        else if (not($job)) then
            (response:set-status-code(404),
             <result success="false" error="record-not-found"/>)
        else if (not($document)) then
            (response:set-status-code(404),
             <result success="false" error="document-not-found"/>)
        else
            let $binaryExists := $file and util:binary-doc-available($collection || "/" || $file)
            let $removeBinary :=
                if ($binaryExists) then
                    xmldb:remove($collection, $file)
                else ()
            let $removeMetadata := update delete $document
            return
                <result
                    success="true"
                    type="{$type}"
                    binaryRemoved="{if ($binaryExists) then 'true' else 'false'}"/>
};

system:as-user($tsh:adminUser, $tsh:adminPassword, local:delete())