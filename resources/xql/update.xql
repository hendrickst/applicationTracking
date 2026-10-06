xquery version "3.1";
import module namespace tsh="tsh" at "./config.xql";
import module namespace request="http://exist-db.org/xquery/request";

declare variable $record := request:get-parameter("record","");
declare variable $id := if($record) then $record else util:uuid();
declare function local:col() as xs:string {$tsh:base||"/"||$id};
declare function local:param($n as xs:string) as xs:string {request:get-parameter($n,"")};
declare function local:ext($n as xs:string) as xs:string {let $e:=lower-case(tokenize($n,"\.")[last()]) return if($e=("pdf","doc","docx")) then $e else ""};

declare function local:upload($i as xs:string,$type as xs:string) as element()? {
 let $p:="documentFile["||$i||"]"
 let $n:=request:get-uploaded-file-name($p)
 let $d:=request:get-uploaded-file-data($p)
 let $e:=local:ext($n)
 return if($n and $d and $e) then
   let $s:=lower-case($type)||"-"||util:uuid()||"."||$e
   let $path:=xmldb:store-as-binary(local:col(),$s,$d)
   let $mime:=if($e="pdf") then "application/pdf" else if($e="doc") then "application/msword" else "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
   let $_:=xmldb:set-mime-type($path,$mime)
   return <document type="{$type}" originalName="{$n}" storedName="{$s}" mimeType="{$mime}"/>
 else ()
};

declare function local:contacts($f as node()) {
 let $count:=xs:integer(request:get-parameter("contactCount","0"))
 let $x:=<contacts>{if($count > 0) then for $i in 0 to ($count - 1) return
   <contact name="{local:param('contacts['||$i||'][name]')}" mail="{local:param('contacts['||$i||'][mail]')}" phone="{local:param('contacts['||$i||'][phone]')}" role="{local:param('contacts['||$i||'][role]')}" linkedin="{local:param('contacts['||$i||'][linkedin]')}"><notes>{local:param('contacts['||$i||'][notes]')}</notes></contact>
 }</contacts>
 return update replace $f//contacts with $x
};

declare function local:notes($f as node()) {
 let $count:=xs:integer(request:get-parameter("noteCount","0"))
 let $x:=<notes>{if($count > 0) then for $i in 0 to ($count - 1) return <note date="{local:param('notes['||$i||'][date]')}" type="{local:param('notes['||$i||'][type]')}">{local:param('notes['||$i||'][note]')}</note>}</notes>
 return update replace $f//notes with $x
};

declare function local:docs($f as node()) {
 let $count:=xs:integer(request:get-parameter("documentCount","0"))
 let $existing:=$f//documents/document
 let $deleted:=if($count > 0) then for $i in 0 to ($count - 1) return request:get-parameter("documentDelete["||$i||"]","")
 let $_:=for $name in $deleted where $name and xmldb:resource-exists(local:col(),$name) return xmldb:remove(local:col(),$name)
 let $keep:=$existing[not(@storedName=$deleted)]
 let $new:=if($count > 0) then for $i in 0 to ($count - 1) return local:upload(xs:string($i),local:param("documentType["||$i||"]")) else ()
 let $x:=<documents>{$keep,$new}</documents>
 return update replace $f//documents with $x
};

declare function local:run() {
 let $c:=local:col()
 let $new:=not(xmldb:collection-available($c))
 let $_:=if($new) then xmldb:create-collection($tsh:base,$id) else ()
 let $_:=if($new) then xmldb:copy-resource($tsh:XMLPath,"blank.xml",$c,$id||".xml") else ()
 let $f:=doc($c||"/"||$id||".xml")
 let $_:=update value $f/job/@id with $id
 let $_:=update value $f/job/company with local:param("companyName")
 let $_:=update value $f/job/url with local:param("url")
 let $_:=update value $f/job/title with local:param("jobTitle")
 let $_:=update value $f/job/dates/@applied with local:param("dateApplied")
 let $_:=update value $f/job/dates/@rejected with local:param("dateRejected")
 let $_:=update value $f/job/status with local:param("status")
 let $_:=local:contacts($f)
 let $_:=local:notes($f)
 let $_:=local:docs($f)
 return response:redirect-to(xs:anyURI("../../index.html"))
};
system:as-user($tsh:adminUser,$tsh:adminPassword,local:run())