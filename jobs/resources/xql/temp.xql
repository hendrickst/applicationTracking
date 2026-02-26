xquery version "3.1";

import module namespace request="http://exist-db.org/xquery/request";

(: get all parameter names :)
let $params := request:get-parameter-names()

(: extract unique note indexes :)
let $indexes :=
  distinct-values(
    for $p in $params
    where starts-with($p, "notes[")
    return replace($p, "notes\[(\d+)\].*", "$1")
  )

return
  <notes>
                        {
                            for $i in $indexes
                            let $date := request:get-parameter(concat("notes[", $i, "][date]"), "")
                            let $note := request:get-parameter(concat("notes[", $i, "][note]"), "")
                            order by xs:integer($i)
                            return
                                <note date="{$date}">{string($note)}</note>
                        }
                        </notes>