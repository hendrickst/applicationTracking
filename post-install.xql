xquery version "3.1";
import module namespace xmldb="http://exist-db.org/xquery/xmldb";

declare variable $base := "/db/jobs";
declare variable $legacy := $base || "/applications";

(: Normalize all supported pre-v2 layouts into /db/jobs/<UUID>/<UUID>.xml.
   This also fixes the earlier layout where the collection itself was named <UUID>.xml. :)
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

(: Old flat collection: /db/jobs/applications/<UUID>.xml :)
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

(: Earlier incorrect layout: /db/jobs/<UUID>.xml/<UUID>.xml.
   Copy every resource, not just the XML, so uploaded documents are preserved. :)
let $_incorrect :=
  for $name in xmldb:get-child-collections($base)
  where ends-with($name, ".xml")
  let $id := replace($name, "\.xml$", "")
  let $source := $base || "/" || $name
  return local:migrate-collection($source, $id)

(: Also normalize direct XML resources if a backup contains them at /db/jobs. :)
let $_direct :=
  for $name in xmldb:get-child-resources($base)
  where ends-with($name, ".xml")
  let $id := replace($name, "\.xml$", "")
  let $target := $base || "/" || $id
  let $_create := if (xmldb:collection-available($target)) then () else xmldb:create-collection($base, $id)
  let $_copy := if ($name = xmldb:get-child-resources($target)) then () else xmldb:copy-resource($base, $name, $target, $name)
  let $_remove := if ($name = xmldb:get-child-resources($base)) then xmldb:remove($base, $name) else ()
  return ()

return ()
