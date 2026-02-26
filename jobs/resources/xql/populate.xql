xquery version "3.1";
import module namespace tsh="tsh" at "./config.xql";

declare variable $record := req:parameter('record');

for $f in collection($tsh:working)[./@id = $record][1]
return
    $f