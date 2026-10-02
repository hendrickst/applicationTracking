xquery version "3.1";

(: Package-manager initialization.
   Ensures /db/jobs exists, then performs a non-destructive migration
   from the former /db/jobs/applications layout if it is present. :)

declare variable $target external;

declare function local:ensure-jobs() {
    if (xmldb:collection-available("/db/jobs")) then
        ()
    else
        xmldb:create-collection("/db", "jobs")
};

declare function local:migrate-legacy() {
    let $legacy := "/db/jobs/applications"
    return
        if (not(xmldb:collection-available($legacy))) then
            <migration source="missing" migrated="0"/>
        else
            let $resources := xmldb:get-child-resources($legacy)[ends-with(., ".xml")]
            let $results :=
                for $resource in $resources
                let $id := substring-before($resource, ".xml")
                let $destination := concat("/db/jobs/", $id)
                let $created :=
                    if (xmldb:collection-available($destination)) then true()
                    else exists(xmldb:create-collection("/db/jobs", $id))
                let $copied :=
                    if (doc-available(concat($destination, "/application.xml"))) then true()
                    else exists(xmldb:copy-resource($legacy, $resource, $destination, "application.xml"))
                let $doc := if (doc-available(concat($destination, "/application.xml"))) then doc(concat($destination, "/application.xml")) else ()
                let $documents :=
                    if ($doc and not($doc/job/documents)) then
                        update insert <documents/> into $doc/job
                    else ()
                let $verified := exists($doc/job) and exists($doc/job/documents)
                return
                    <record id="{$id}" created="{$created}" copied="{$copied}" verified="{$verified}"/>
            let $allVerified := every $result in $results satisfies xs:boolean($result/@verified)
            let $removed :=
                if ($allVerified) then (
                    for $resource in $resources
                    return xmldb:remove($legacy, $resource),
                    xmldb:remove($legacy),
                    true()
                )
                else false()
            return
                <migration source="{$legacy}"
                           migrated="{count($results[@verified = 'true'])}"
                           total="{count($results)}"
                           removed="{$removed}">
                    {$results}
                </migration>
};

local:ensure-jobs(),
local:migrate-legacy()