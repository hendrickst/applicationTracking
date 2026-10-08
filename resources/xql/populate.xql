xquery version "3.1";
import module namespace tsh="tsh" at "./config.xql";
declare variable $record := request:get-parameter("record","");
let $c := $tsh:base || "/" || $record
return if ($record and xmldb:collection-available($c) and doc-available($c||"/"||$record||".xml")) then doc($c||"/"||$record||".xml") else ()