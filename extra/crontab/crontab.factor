! Copyright (C) 2018 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors arrays ascii assocs calendar calendar.english
calendar.private combinators io kernel literals locals math
math.order math.parser math.ranges sequences splitting ;

IN: crontab

:: parse-value ( value quot: ( value -- value' ) seq -- value )
    value {
        { [ CHAR: , over member? ] [
            "," split [ quot seq parse-value ] map concat ] }
        { [ dup "*" = ] [ drop seq ] }
        { [ CHAR: / over member? ] [
            "/" split1 [ quot seq parse-value 0 over length 1 - ] dip
            string>number <range> swap nths ] }
        { [ CHAR: - over member? ] [
            "-" split1 quot bi@ [a,b] ] }
        [ quot call 1array ]
    } cond ; inline recursive

: parse-day ( str -- n )
    dup string>number [ ] [
        >lower $[ day-abbreviations3 [ >lower ] map ] index
    ] ?if ;

: parse-month ( str -- n )
    dup string>number [ ] [
        >lower $[ month-abbreviations [ >lower ] map ] index
    ] ?if ;

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

: parse-cronentry ( entry -- cronentry )
    " " split1 [ aliases ?at drop ] dip " " glue
    " " split1 " " split1 " " split1 " " split1 " " split1 {
        [ [ string>number ] T{ range f 0 60 1 } parse-value ]
        [ [ string>number ] T{ range f 0 24 1 } parse-value ]
        [ [ string>number ] T{ range f 0 31 1 } parse-value ]
        [ [ parse-month ] T{ range f 0 12 1 } parse-value ]
        [ [ parse-day ] T{ range f 0 7 1 } parse-value ]
        [ ]
    } spread cronentry boa ;

:: next-time-after ( cronentry timestamp -- )

    timestamp month>> :> month
    cronentry months>> [ month >= ] find nip [
        dup month = [ drop f ] [ timestamp month<< t ] if
    ] [
        timestamp cronentry months>> first >>month 1 +year
    ] if* [ cronentry timestamp next-time-after ] when

    timestamp hour>> :> hour
    cronentry hours>> [ hour >= ] find nip [
        dup hour = [ drop f ] [
            timestamp hour<< 0 timestamp minute<< t
        ] if
    ] [
        timestamp cronentry hours>> first >>hour 1 +day
    ] if* [ cronentry timestamp next-time-after ] when

    timestamp minute>> :> minute
    cronentry minutes>> [ minute >= ] find nip [
        dup minute = [ drop f ] [ timestamp minute<< t ] if
    ] [
        timestamp cronentry minutes>> first >>minute 1 +hour
    ] if* [ cronentry timestamp next-time-after ] when

    timestamp day-of-week :> weekday
    cronentry days-of-week>> [ weekday >= ] find nip [
        cronentry days-of-week>> first 7 +
    ] unless* weekday -

    timestamp day>> :> day
    cronentry days>> [ day >= ] find nip [
        day -
    ] [
        timestamp 1 months time+
        cronentry days>> first >>day
        day-of-year timestamp day-of-year -
    ] if*

    min [
        timestamp swap +day drop
        cronentry timestamp next-time-after
    ] unless-zero ;

: next-time ( cronentry -- timestamp )
    now 0 >>second [ next-time-after ] keep ;

: parse-crontab ( -- entries )
    lines [ [ f ] [ parse-cronentry ] if-empty ] map harvest ;
