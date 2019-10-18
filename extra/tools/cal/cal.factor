! Copyright (C) 2016 John Benediktsson
! See http://factorcode.org/license.txt for BSD license
USING: accessors calendar calendar.english combinators
command-line formatting grouping io kernel math.parser
math.ranges namespaces sequences sequences.extras strings.tables
;
IN: tools.cal

<PRIVATE

: days ( timestamp -- days )
    beginning-of-month
    [ day-of-week "  " <repetition> ]
    [ days-in-month [1,b] [ "%2d" sprintf ] map ] bi append
    42 "  " pad-tail ;

: month-header ( timestamp -- str )
    "%B %Y" strftime 20 CHAR: \s pad-center ;

: year-header ( timestamp -- str )
    "%Y" strftime 64 CHAR: \s pad-center ;

: month-rows ( timestamp -- rows )
    days 7 group day-abbreviations2 prefix format-table ;

PRIVATE>

: month. ( timestamp -- )
    [ month-header print ] [ month-rows [ print ] each ] bi ;

: year. ( timestamp -- )
    dup year-header print nl 12 [1,b] [
        >>month [ month-rows ] [ month-name ] bi
        20 CHAR: \s pad-center prefix
    ] with map 3 group
    [ first3 [ "%s  %s  %s\n" printf ] 3each ] each ;

<PRIVATE

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

PRIVATE>

: run-cal ( -- )
    cal-args [ year. ] [ month. ] if ;

MAIN: run-cal
