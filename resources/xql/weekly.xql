xquery version "3.1";

import module namespace xmldb="http://exist-db.org/xquery/xmldb";

(: Return each application.xml exactly once. eXist-db's collection()
   may include descendant collections, so recursive collection() calls
   can double-count records. :)
declare function local:jobs($collection as xs:string) as element(job)* {
    let $here :=
        for $resource in xmldb:get-child-resources($collection)[. = "application.xml"]
        return doc(concat($collection, "/", $resource))/job
    let $children := xmldb:get-child-collections($collection)
    return (
        $here,
        for $child in $children
        let $childPath :=
            if (starts-with($child, "/")) then $child
            else concat($collection, "/", $child)
        return local:jobs($childPath)
    )
};

let $apps := local:jobs("/db/jobs")
let $total := count($apps)
let $rejected := count($apps[normalize-space(status) = "Rejected"])
return
    <weekly-data total="{$total}" rejected="{$rejected}">
        {
            for $job in $apps[dates/@applied or dates/@rejected]
            return
                <application
                    applied="{string($job/dates/@applied)}"
                    rejected="{string($job/dates/@rejected)}"
                    status="{normalize-space(string($job/status))}"/>
        }
    </weekly-data>