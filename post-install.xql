xquery version "3.1";
import module namespace xmldb="http://exist-db.org/xquery/xmldb";
declare variable $base := "/db/jobs";
declare variable $old := $base || "/applications";
if (xmldb:collection-available($old)) then
  let $_ := for $name in xmldb:get-child-resources($old)
            where ends-with($name,".xml")
            let $id := replace($name,"\.xml$","")
            let $c := $base || "/" || $id
            let $_c := if(xmldb:collection-available($c)) then () else xmldb:create-collection($base,$id)
            let $_x := if(not(xmldb:resource-exists($c,$name))) then xmldb:copy-resource($old,$name,$c,$name) else ()
            return ()
  let $_remove := xmldb:remove($old)
  return ()
else ()