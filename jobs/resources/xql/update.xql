xquery version "3.1";
import module namespace tsh="tsh" at "./config.xql";
import module namespace request="http://exist-db.org/xquery/request";


    declare variable $uniqueID := util:uuid();
    
    declare variable $record := req:parameter('record');
    declare variable $companyName := req:parameter('companyName');
    declare variable $url := req:parameter('url');
    declare variable $jobTitle := req:parameter('jobTitle');
    declare variable $dateApplied := req:parameter('dateApplied');
    declare variable $dateRejected := req:parameter('dateRejected');
    declare variable $status := req:parameter('status');
    declare variable $notes := req:parameter('notes');
    
    

declare function local:check() {
    if ($record) then
        let $fileName := $tsh:working || '/' || $record || '.xml'
        let $file := doc($fileName)
        let $update := local:updateFile($file)
        return
            response:redirect-to(xs:anyURI('../../index.html'))
    else
        let $fileName := $uniqueID || ".xml"
        let $createNew := xmldb:copy-resource($tsh:XMLPath, 'blank.xml', $tsh:working, $fileName)
        let $file := doc($tsh:working || '/' || $fileName)
        let $update := local:updateFile($file)
        return
            response:redirect-to(xs:anyURI('../../index.html'))
};

declare function local:updateFile($file){
    let $updateRecord := if ($record) then local:update($file, '/job/@id', $record) else local:update($file, '/job/@id', $uniqueID)
    let $updateCompany := local:update($file, '//company', $companyName)
    let $updateUrl := local:update($file, '//url', $url)
    let $updateTitle := local:update($file, '//title', $jobTitle)
    let $updateDateApplied := local:update($file, '//@applied', $dateApplied)
    let $updateDateRejected := local:update($file, '//@rejected', $dateRejected)
    let $updateStatus := local:update($file, '//status', $status)
    return
        local:updateNotes($file, $notes)
};

declare function local:update($file, $xpath, $value) {
    if ($value) then
        let $path := util:eval-inline($file, $xpath)
        return
            update value $path with $value
    else
        ()
};

declare function local:updateNotes($file, $values) {

    (: Get all parameter names. :)
    let $params := request:get-parameter-names()

    (: Extract unique note indexes :)
    let $indexes :=
        distinct-values(
            for $p in $params
            where starts-with($p, "notes[")
            return
                replace($p, "notes\[(\d+)\].*", "$1")
        )

    let $builtXML :=    <notes>
                        {
                            for $i in $indexes
                            let $date := request:get-parameter(concat("notes[", $i, "][date]"), "")
                            let $note := request:get-parameter(concat("notes[", $i, "][note]"), "")
                            order by xs:integer($i)
                            return
                                <note date="{$date}">{string($note)}</note>
                        }
                        </notes>
    return
        update replace $file//notes with $builtXML
};

    system:as-user($tsh:adminUser, $tsh:adminPassword, local:check())
    
    