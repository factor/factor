! Copyright (C) 2024 nomennescio.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs calendar calendar.format combinators
db.tuples formatting furnace.actions html.forms
http.server.responses io io.streams.string kernel math.parser
sequences webapps.mason.backend webapps.mason.utils ;
IN: webapps.mason.benchmarks

: benchmark-results ( -- response )
    [ selected-benchmarks ] with-mason-db
    [
        "run,timestamp (UTC),host,os,cpu,git,name,duration (ns)" print
        '[
            [ run-id>> ] [ name>> ] [ duration>> ] tri
            [ _ at { [ run-id>> ] [ timestamp>> timestamp>iso8601Z ] [ host-name>> ] [ os>> ] [ cpu>> ] [ git-id>> ] } cleave ] 2dip
            "%s,%s,%s,%s,%s,%s,%s,%s\n" printf
        ] each
    ] with-string-writer <text-content> ;

: <benchmark-results-action> ( -- action )
    <action>
    [ validate-benchmark-selection ] >>init
    [ benchmark-results ] >>display ;
