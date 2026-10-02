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

declare function local:extension($filename as xs:string?) as xs:string {
    if (not($filename)) then ""
    else lower-case(replace($filename, "^.*\\.([^.]+)$", "$1"))
};

declare function local:resumeMime($filename as xs:string) as xs:string {
    switch (local:extension($filename))
        case "pdf" return "application/pdf"
        case "doc" return "application/msword"
        case "docx" return "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        default return "application/octet-stream"
};

declare function local:validResume($filename as xs:string?) as xs:boolean {
    local:extension($filename) = ("pdf", "doc", "docx")
};

declare function local:validPosting($filename as xs:string?) as xs:boolean {
    local:extension($filename) = "pdf"
};

declare function local:storeUpload(
    $collection as xs:string,
    $param as xs:string,
    $elementName as xs:string,
    $filePrefix as xs:string,
    $mime as xs:string
) as element()? {
    let $originalName := request:get-uploaded-file-name($param)
    let $file := request:get-uploaded-file($param)
    return
        if ($originalName and $file) then
            let $internalName := $filePrefix || "-" || util:uuid() || "." || local:extension($originalName)
            let $stored := xmldb:store-as-binary($collection, $internalName, $file)
            let $setMime := xmldb:set-mime-type(xs:anyURI($stored), $mime)
            return
                element {$elementName} {
                    attribute file {$internalName},
                    attribute originalName {$originalName},
                    attribute type {$mime},
                    attribute uploaded {string(current-date())},
                    if ($elementName = "jobPosting") then
                        attribute captured {string(current-date())}
                    else ()
                }
        else
            ()
};

declare function local:removeOldDocument($collection as xs:string, $node as element()?) {
    let $oldFile := string($node/@file)
    return
        if ($oldFile and util:binary-doc-available($collection || '/' || $oldFile)) then
            xmldb:remove($collection, $oldFile)
        else
            ()
};

declare function local:updateFile($file, $collection as xs:string){
    let $updateRecord := if ($record) then local:update($file, '/job/@id', $record) else local:update($file, '/job/@id', $uniqueID)
    let $updateCompany := local:update($file, '//company', $companyName)
    let $updateUrl := local:update($file, '//url', $url)
    let $updateTitle := local:update($file, '//title', $jobTitle)
    let $updateDateApplied := local:update($file, '//@applied', $dateApplied)
    let $updateDateRejected := local:update($file, '//@rejected', $dateRejected)
    let $updateStatus := local:update($file, '//status', $status)

    let $updateContacts := local:updateContacts($file)
    let $updateNotes := local:updateNotes($file, $notes)

    let $oldResume := $file/job/documents/resume
    let $oldPosting := $file/job/documents/jobPosting

    let $resumeName := request:get-uploaded-file-name('resumeFile')
    let $postingName := request:get-uploaded-file-name('jobPostingFile')

    let $newResume :=
        if ($resumeName and local:validResume($resumeName)) then
            local:storeUpload($collection, 'resumeFile', 'resume', 'resume', local:resumeMime($resumeName))
        else ()

    let $newPosting :=
        if ($postingName and local:validPosting($postingName)) then
            local:storeUpload($collection, 'jobPostingFile', 'jobPosting', 'posting', 'application/pdf')
        else ()

    let $documents :=
        <documents>{
            if ($newResume) then $newResume else $oldResume,
            if ($newPosting) then $newPosting else $oldPosting
        }</documents>

    let $replaceDocuments := update replace $file/job/documents with $documents

    let $removeResume :=
        if ($newResume and $oldResume/@file/string() ne $newResume/@file/string())
        then local:removeOldDocument($collection, $oldResume)
        else ()

    let $removePosting :=
        if ($newPosting and $oldPosting/@file/string() ne $newPosting/@file/string())
        then local:removeOldDocument($collection, $oldPosting)
        else ()

    return ($updateContacts, $updateNotes, $replaceDocuments, $removeResume, $removePosting)
};

declare function local:update($file, $xpath, $value) {
    if ($value) then
        let $path := util:eval-inline($file, $xpath)
        return update value $path with $value
    else ()
};

declare function local:updateNotes($file, $values) {
    let $params := request:get-parameter-names()
    let $indexes :=
        distinct-values(
            for $p in $params
            where starts-with($p, "notes[")
            return replace($p, "notes\\[(\\d+)\\].*", "$1")
        )
    let $builtXML :=
        <notes>{
            for $i in $indexes
            let $date := request:get-parameter(concat("notes[", $i, "][date]"), "")
            let $type := request:get-parameter(concat("notes[", $i, "][type]"), "Other")
            let $note := request:get-parameter(concat("notes[", $i, "][note]"), "")
            order by xs:integer($i)
            return <note date="{$date}" type="{$type}">{string($note)}</note>
        }</notes>
    return update replace $file//notes with $builtXML
};

declare function local:updateContacts($file) {
    let $params := request:get-parameter-names()
    let $indexes :=
        distinct-values(
            for $p in $params
            where starts-with($p, "contacts[")
            return replace($p, "contacts\\[(\\d+)\\].*", "$1")
        )
    let $builtXML :=
        <contacts>{
            for $i in $indexes
            let $name := request:get-parameter(concat("contacts[", $i, "][name]"), "")
            let $mail := request:get-parameter(concat("contacts[", $i, "][mail]"), "")
            let $phone := request:get-parameter(concat("contacts[", $i, "][phone]"), "")
            let $role := request:get-parameter(concat("contacts[", $i, "][role]"), "Other")
            order by xs:integer($i)
            return <contact name="{$name}" mail="{$mail}" phone="{$phone}" role="{$role}"/>
        }</contacts>
    return update replace $file//contacts with $builtXML
};

declare function local:check() {
    let $resumeName := request:get-uploaded-file-name('resumeFile')
    let $postingName := request:get-uploaded-file-name('jobPostingFile')
    return
        if ($resumeName and not(local:validResume($resumeName))) then
            response:redirect-to(xs:anyURI('../../update.html?record=' || $record || '&error=resume'))
        else if ($postingName and not(local:validPosting($postingName))) then
            response:redirect-to(xs:anyURI('../../update.html?record=' || $record || '&error=posting'))
        else if ($record) then
            let $collection := $tsh:working || '/' || $record
            let $file := doc($collection || '/application.xml')
            let $update := local:updateFile($file, $collection)
            return response:redirect-to(xs:anyURI('../../index.html'))
        else
            let $id := $uniqueID
            let $collection := $tsh:working || '/' || $id
            let $createCollection := xmldb:create-collection($tsh:working, $id)
            let $createFile := xmldb:copy-resource($tsh:XMLPath, 'blank.xml', $collection, 'application.xml')
            let $file := doc($collection || '/application.xml')
            let $update := local:updateFile($file, $collection)
            return response:redirect-to(xs:anyURI('../../index.html'))
};

system:as-user($tsh:adminUser, $tsh:adminPassword, local:check())
