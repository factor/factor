! Copyright (C) 2016 John Benediktsson
! See https://factorcode.org/license.txt for BSD license
USING: accessors calendar calendar.format combinators
command-line kernel math.parser namespaces sequences
sequences.extras ;
IN: tools.cal

: cal-args ( -- timestamp year? )
    now command-line get [
        f
    ] [
        dup first {
            { "-m" [ rest ?first2 swap f ] }
            { "-y" [ rest ?first2 dup [ swap ] when t ] }
            [ drop ?first2 dup [ swap ] when dup not ]
        } case [
            [ string>number ] bi@
            [ [ >>year ] when* ]
            [ [ >>month ] when* ] bi*
        ] dip
    ] if-empty ;

: run-cal ( -- )
    cal-args [ year. ] [ month. ] if ;

MAIN: run-cal
