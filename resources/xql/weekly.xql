xquery version "3.1";
import module namespace xmldb="http://exist-db.org/xquery/xmldb";

declare variable $base := "/db/jobs";
declare variable $legacy := $base || "/applications";

declare function local:copy-resources($source as xs:string, $target as xs:string) {
  for $name in xmldb:get-child-resources($source)
  return
    if ($name = xmldb:get-child-resources($target)) then ()
    else xmldb:copy-resource($source, $name, $target, $name)
};

declare function local:migrate-collection($source as xs:string, $id as xs:string) {
  let $target := $base || "/" || $id
  let $_create := if (xmldb:collection-available($target)) then () else xmldb:create-collection($base, $id)
  let $_copy := local:copy-resources($source, $target)
  let $_remove := if (xmldb:get-child-resources($source) = ()) then xmldb:remove($source) else ()
  return ()
};

declare function local:migrate-resource($source as xs:string, $name as xs:string) {
  let $id := replace($name, "\.xml$", "")
  let $target := $base || "/" || $id
  let $_create := if (xmldb:collection-available($target)) then () else xmldb:create-collection($base, $id)
  let $_copy := if ($name = xmldb:get-child-resources($target)) then () else xmldb:copy-resource($source, $name, $target, $name)
  return ()
};

let $_legacy :=
  if (xmldb:collection-available($legacy)) then
    (
      for $name in xmldb:get-child-resources($legacy)
      where ends-with($name, ".xml")
      let $id := replace($name, "\.xml$", "")
      return local:migrate-resource($legacy, $name),
      if (xmldb:get-child-resources($legacy) = ()) then xmldb:remove($legacy) else ()
    )
  else ()

let $_incorrect :=
  for $name in xmldb:get-child-collections($base)
  where ends-with($name, ".xml")
  let $id := replace($name, "\.xml$", "")
  return local:migrate-collection($base || "/" || $name, $id)

let $_direct :=
  for $name in xmldb:get-child-resources($base)
  where ends-with($name, ".xml")
  let $id := replace($name, "\.xml$", "")
  let $target := $base || "/" || $id
  let $_create := if (xmldb:collection-available($target)) then () else xmldb:create-collection($base, $id)
  let $_copy := if ($name = xmldb:get-child-resources($target)) then () else xmldb:copy-resource($base, $name, $target, $name)
  let $_remove := xmldb:remove($base, $name)
  return ()

let $apps :=
  for $id in xmldb:get-child-collections($base)
  where not(ends-with($id, ".xml"))
  let $j := doc($base || "/" || $id || "/" || $id || ".xml")
  where exists($j/job)
  return $j/job

return <weekly-data total="{count($apps)}" rejected="{count($apps[status="Rejected"])}">{for $j in $apps[dates/@applied or dates/@rejected] return <application applied="{string($j/dates/@applied)}" rejected="{string($j/dates/@rejected)}" status="{normalize-space($j/status/text())}"/>}</weekly-data>
