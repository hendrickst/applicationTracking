xquery version "3.1";
import module namespace tsh="tsh" at "./config.xql";
import module namespace request="http://exist-db.org/xquery/request";

(: One-time migration:
   /db/jobs/applications/{uuid}.xml
   becomes
   /db/jobs/{uuid}/application.xml

   The script copies and verifies every legacy XML first.
   Pass ?removeLegacy=true to delete the old flat XML resources and
   the /db/jobs/applications collection after successful verification.
:)

declare variable $legacy := "/db/jobs/applications";
declare variable $removeLegacy := lower-case(req:parameter("removeLegacy")) = "true";

declare function local:migrate() {
    if (not(xmldb:collection-available($legacy))) then
        <migration source="missing" removed="false">
            <message>No legacy /db/jobs/applications collection was found.</message>
        </migration>
    else
        let $resources := xmldb:get-child-resources($legacy)[ends-with(., ".xml")]
        let $results :=
            for $resource in $resources
            let $id := substring-before($resource, ".xml")
            let $target := $tsh:base || "/" || $id
            let $collectionCreated :=
                if (xmldb:collection-available($target)) then true()
                else exists(xmldb:create-collection($tsh:base, $id))
            let $copied :=
                if (doc-available($target || "/application.xml")) then true()
                else exists(xmldb:copy-resource($legacy, $resource, $target, "application.xml"))
            let $document := if (doc-available($target || "/application.xml")) then doc($target || "/application.xml") else ()
            let $addDocuments :=
                if ($document and not($document/job/documents))
                then update insert <documents/> into $document/job
                else ()
            let $verified := doc-available($target || "/application.xml") and exists(doc($target || "/application.xml")/job/documents)
            return
                <record
                    id="{$id}"
                    source="{$legacy || '/' || $resource}"
                    target="{$target || '/application.xml'}"
                    collection-created="{$collectionCreated}"
                    copied="{$copied}"
                    verified="{$verified}"/>
        let $allVerified := every $result in $results satisfies xs:boolean($result/@verified)
        let $removed :=
            if ($removeLegacy and $allVerified) then (
                for $resource in $resources
                return xmldb:remove($legacy, $resource),
                xmldb:remove($legacy),
                true()
            )
            else false()
        return
            <migration
                source="{$legacy}"
                target="{$tsh:base}"
                count="{count($resources)}"
                verified="{count($results[@verified = "true"])}"
                removed="{$removed}"
                dry-run="{not($removeLegacy)}">
                {$results}
            </migration>
};

system:as-user($tsh:adminUser, $tsh:adminPassword, local:migrate())