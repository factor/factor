! Copyright (C) 2018 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors arrays ascii assocs calendar calendar.english
calendar.private circular combinators combinators.short-circuit
io kernel literals math math.order math.parser ranges sequences
sets sorting splitting ;

IN: crontab

ERROR: invalid-cronentry value ;

:: parse-value ( value quot: ( value -- value' ) seq -- value )
    value {
        { [ CHAR: , over member? ] [
            "," split [ quot seq parse-value ] map concat ] }
        { [ dup "*" = ] [ drop seq ] }
        { [ CHAR: / over member? ] [
            "/" split1 [
                quot seq parse-value
                dup length 1 = [ seq swap first seq first - ] [ 0 ] if
                over length dup 7 = [ [ <circular> ] 2dip ] [ 1 - ] if
            ] dip string>number <range> swap nths ] }
        { [ CHAR: - over member? ] [
            "-" split1 quot bi@ [a..b] ] }
        [ quot call 1array ]
    } cond members sort ; inline recursive

: parse-day ( str -- n )
    [ string>number dup 7 = [ drop 0 ] when ] [
        >lower $[ day-abbreviations3 [ >lower ] map ] index
    ] ?unless ;

: parse-month ( str -- n )
    [ string>number ] [
        >lower $[ month-abbreviations [ >lower ] map ] index
    ] ?unless ;

TUPLE: cronentry minutes hours days months days-of-week command ;

CONSTANT: aliases H{
    { "@yearly"   "0 0 1 1 *" }
    { "@annually" "0 0 1 1 *" }
    { "@monthly"  "0 0 1 * *" }
    { "@weekly"   "0 0 * * 0" }
    { "@daily"    "0 0 * * *" }
    { "@midnight" "0 0 * * *" }
    { "@hourly"   "0 * * * *" }
}

: check-cronentry ( cronentry -- cronentry )
    dup {
        [ days-of-week>> [ 0 6 between? ] all? ]
        [ months>> [ 1 12 between? ] all? ]
        [
            [ days>> 1 ] [ months>> ] bi [
                { 0 31 29 31 30 31 30 31 31 30 31 30 31 } nth
            ] map supremum [ between? ] 2curry all?
        ]
        [ minutes>> [ 0 59 between? ] all? ]
        [ hours>> [ 0 23 between? ] all? ]
    } 1&& [ invalid-cronentry ] unless ;

: parse-cronentry ( entry -- cronentry )
    " " split1 [ aliases ?at drop ] dip " " glue
    " " split1 " " split1 " " split1 " " split1 " " split1 {
        [ [ string>number ] T{ range f 0 60 1 } parse-value ]
        [ [ string>number ] T{ range f 0 24 1 } parse-value ]
        [ [ string>number ] T{ range f 1 31 1 } parse-value ]
        [ [ parse-month ] T{ range f 1 12 1 } parse-value ]
        [ [ parse-day ] T{ range f 0 7 1 } parse-value ]
        [ ]
    } spread cronentry boa check-cronentry ;

<PRIVATE

:: (next-time-after) ( cronentry timestamp -- )

    f ! should we keep searching for a matching time

    timestamp month>> :> month
    cronentry months>> [ month >= ] find nip
    dup month = [ drop ] [
        [ cronentry months>> first timestamp 1 +year drop ] unless*
        timestamp 1 >>day 0 >>hour 0 >>minute month<< drop t
    ] if

    timestamp day-of-week :> weekday
    cronentry days-of-week>> [ weekday >= ] find nip [
        cronentry days-of-week>> first 7 +
    ] unless* weekday - :> days-to-weekday

    timestamp day>> :> day
    cronentry days>> [ day >= ] find nip [
        cronentry days>> first timestamp days-in-month +
    ] unless* day - :> days-to-day

    cronentry days-of-week>> length 7 =
    cronentry days>> length 31 = 2array
    {
        { { f t } [ days-to-weekday ] }
        { { t f } [ days-to-day ] }
        [ drop days-to-weekday days-to-day min ]
    } case [
        timestamp 0 >>hour 0 >>minute swap +day 2drop t
    ] unless-zero

    timestamp hour>> :> hour
    cronentry hours>> [ hour >= ] find nip
    dup hour = [ drop ] [
        [ cronentry hours>> first timestamp 1 +day drop ] unless*
        timestamp 0 >>minute hour<< drop t
    ] if

    timestamp minute>> :> minute
    cronentry minutes>> [ minute >= ] find nip
    dup minute = [ drop ] [
        [ cronentry minutes>> first timestamp 1 +hour drop ] unless*
        timestamp minute<< drop t
    ] if

    [ cronentry timestamp (next-time-after) ] when ;

PRIVATE>

: next-time-after ( cronentry timestamp -- timestamp )
    1 minutes time+ 0 >>second [ (next-time-after) ] keep ;

: next-time ( cronentry -- timestamp )
    now next-time-after ;

: next-times-after ( cronentry n timestamp -- timestamps )
    swap [ dupd next-time-after dup ] replicate 2nip ;

: next-times ( cronentry n -- timestamps )
    now next-times-after ;

: read-crontab ( -- entries )
    read-lines harvest [ parse-cronentry ] map ;
