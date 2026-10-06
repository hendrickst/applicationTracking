xquery version "3.1";
import module namespace xmldb="http://exist-db.org/xquery/xmldb";
declare variable $base := "/db/jobs";
let $apps := for $id in xmldb:get-child-collections($base) let $j:=doc($base||"/"||$id||"/"||$id||".xml") where exists($j/job) return $j/job
return <weekly-data total="{count($apps)}" rejected="{count($apps[status="Rejected"])}">{for $j in $apps[dates/@applied or dates/@rejected] return <application applied="{string($j/dates/@applied)}" rejected="{string($j/dates/@rejected)}" status="{normalize-space($j/status)}"/>}</weekly-data>