xquery version "3.1";
import module namespace tsh="tsh" at "./config.xql";
import module namespace xmldb="http://exist-db.org/xquery/xmldb";
import module namespace request="http://exist-db.org/xquery/request";
import module namespace util="http://exist-db.org/xquery/util";
import module namespace system="http://exist-db.org/xquery/system";

declare variable $local:record := request:get-parameter("record", "");
declare variable $local:action := request:get-parameter("action", "load");
declare variable $local:collection := $tsh:base || "/" || $local:record;
declare variable $local:messages := request:get-parameter("messages", "[]");

declare function local:valid-record() as xs:boolean {
  matches($local:record, "^[A-Za-z0-9-]+$") and
  xmldb:collection-available($local:collection) and
  doc-available($local:collection || "/" || $local:record || ".xml")
};

declare function local:run() {
  if (not(local:valid-record())) then
    (response:set-status-code(400), <error status="error">Missing or invalid application record.</error>)
  else if ($local:action = "load") then
    if (doc-available($local:collection || "/chat.xml")) then doc($local:collection || "/chat.xml")/conversation
    else <conversation applicationId="{$local:record}" updated=""/>
  else if ($local:action = "save") then
    let $parsed := parse-json($local:messages)
    let $items := if ($parsed instance of array(*)) then $parsed?* else ()
    let $safe := for $m in $items
      let $role := string($m?role)
      let $text := string($m?text)
      let $time := string($m?time)
      where $role = ("user", "model")
      return <message role="{$role}" time="{if ($time castable as xs:dateTime) then $time else current-dateTime()}">{$text}</message>
    let $conversation := <conversation applicationId="{$local:record}" updated="{current-dateTime()}">{$safe}</conversation>
    let $_ := xmldb:store($local:collection, "chat.xml", $conversation)
    return <result status="ok"/>
  else
    (response:set-status-code(400), <error status="error">Unsupported action.</error>)
};

response:set-header("Content-Type", "application/xml; charset=utf-8"),
system:as-user($tsh:adminUser, $tsh:adminPassword, local:run())
