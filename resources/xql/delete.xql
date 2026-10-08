xquery version "3.1";
import module namespace xmldb="http://exist-db.org/xquery/xmldb";
import module namespace request="http://exist-db.org/xquery/request";
import module namespace response="http://exist-db.org/xquery/response";
import module namespace tsh="tsh" at "./config.xql";

declare variable $record := request:get-parameter("record", "");

declare function local:delete-collection($path as xs:string) {
    if (xmldb:collection-available($path)) then
        (
            for $resource in xmldb:get-child-resources($path)
            return xmldb:remove($path, $resource),
            for $child in xmldb:get-child-collections($path)
            return local:delete-collection($path || "/" || $child),
            xmldb:remove($path)
        )
    else ()
};

let $target := $tsh:base || "/" || $record
return
    system:as-user(
        $tsh:adminUser,
        $tsh:adminPassword,
        if ($record and xmldb:collection-available($target)) then
            (
                local:delete-collection($target),
                response:redirect-to(xs:anyURI("../../index.html"))
            )
        else
            (
                response:set-status-code(404),
                "Application not found"
            )
    )
