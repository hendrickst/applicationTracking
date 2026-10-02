xquery version "3.1";
import module namespace tsh="tsh" at "./config.xql";

declare variable $record := req:parameter('record');

let $path := $tsh:working || '/' || $record || '/application.xml'
return
    if ($record and doc-available($path)) then
        doc($path)
    else
        ()