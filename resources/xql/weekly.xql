xquery version "3.1";

let $apps := collection("/db/jobs/applications")/job
return
    <weekly-data>
        {
            for $job in $apps[dates/@applied]
            return
                <application
                    applied="{string($job/dates/@applied)}"
                    status="{normalize-space(string($job/status))}"/>
        }
    </weekly-data>