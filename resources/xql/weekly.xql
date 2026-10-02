xquery version "3.1";

declare function local:jobs($collection as xs:string) as element(job)* {
    let $here := collection($collection)/job
    let $children := xmldb:get-child-collections($collection)
    return (
        $here,
        for $child in $children
        return local:jobs($child)
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