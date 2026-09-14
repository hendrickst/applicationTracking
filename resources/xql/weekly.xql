xquery version "3.1";

let $apps := collection("/db/jobs/applications")/job
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