! Copyright (C) 2018 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors arrays ascii assocs assocs.extras calendar
calendar.english calendar.format calendar.parser
calendar.private circular combinators combinators.short-circuit
io kernel literals math math.order math.parser prettyprint
random ranges sequences sets sorting splitting ;

IN: crontab

ERROR: invalid-cronentry value ;

TUPLE: cronentry minutes hours days months days-of-week command ;

<PRIVATE

:: parse-range ( from/f to/f quot: ( value -- value' ) seq -- from to )
    from/f to/f
    [ [ seq first ] quot if-empty ]
    [ [ seq last ] quot if-empty ] bi* ; inline

:: parse-value ( value quot: ( value -- value' ) seq -- value )
    value {
        { [ dup "*" = ] [ drop seq ] }
        { [ CHAR: , over member? ] [
            "," split [ quot seq parse-value ] map concat ] }
        { [ CHAR: / over member? ] [
            "/" split1 [
                quot seq parse-value dup length 1 =
                [ seq swap first seq index seq length ]
                [ 0 over length ] if 1 -
            ] dip string>number <range> swap nths ] }
        { [ CHAR: - over member? ] [
            "-" split1 quot seq parse-range [a..b] ] }
        { [ CHAR: ~ over member? ] [
            "~" split1 quot seq parse-range [a..b] random 1array ] }
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
            ] map maximum [ between? ] 2curry all?
        ]
        [ minutes>> [ 0 59 between? ] all? ]
        [ hours>> [ 0 23 between? ] all? ]
    } 1&& [ invalid-cronentry ] unless ;

PRIVATE>

: parse-cronentry ( entry -- cronentry )
    " " split1 [ aliases ?at drop ] dip " " glue
    " " split1 " " split1 " " split1 " " split1 " " split1 {
        [ [ string>number ] T{ range f 0 60 1 } parse-value ]
        [ [ string>number ] T{ range f 0 24 1 } parse-value ]
        [ [ string>number ] T{ range f 1 31 1 } parse-value ]
        [ [ parse-month ] T{ range f 1 12 1 } parse-value ]
        [ [ parse-day ] T{ circular f T{ range f 0 7 1 } 1 } parse-value ]
        [ ]
    } spread cronentry boa check-cronentry ;

<PRIVATE

: ?parse-cronentry ( entry -- cronentry )
    dup cronentry? [ parse-cronentry ] unless ;

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
    [ ?parse-cronentry ] dip 1 minutes time+ 0 >>second
    [ (next-time-after) ] keep ;

: next-time ( cronentry -- timestamp )
    now next-time-after ;

: next-times-after ( cronentry n timestamp -- timestamps )
    swap [ dupd next-time-after dup ] replicate 2nip ;

: next-times-from-until ( cronentry from-timestamp until-timestamp -- timestamps )
    [ dup second>> 0 = [ 1 minutes time- ] when ] dip
    '[ dupd next-time-after dup dup _ before? ] [ ] produce 3nip ;

: next-times-until ( cronentry timestamp -- timestamps )
    [ now start-of-minute ] dip next-times-from-until ;

: next-times ( cronentry n -- timestamps )
    now next-times-after ;

: read-crontab ( -- entries )
    read-lines harvest [ parse-cronentry ] map ;

: group-crons ( cronstrings from-timestamp until-timestamp -- entries )
    '[ _ _ next-times-from-until [ timestamp>unix-time ] map ] zip-with
    [ first2 [ 2array ] with map ] map concat
    [ nip ] collect-key-by sort-keys ;

: group-crons-for-duration-from ( cronstrings duration from-timestamp -- entries )
    tuck time+ group-crons ;

: group-crons-for-duration ( cronstrings duration -- entries )
    now group-crons-for-duration-from ;

: crons-for-minute ( cronstrings timestamp -- entries )
    start-of-minute dup end-of-minute group-crons ;

: crons-for-hour ( cronstrings timestamp -- entries )
    start-of-hour dup end-of-hour group-crons ;

: crons-for-day ( cronstrings timestamp -- entries )
    start-of-day dup end-of-day group-crons ;

: crons-for-week ( cronstrings timestamp -- entries )
    start-of-week dup end-of-week group-crons ;

: crons-for-month ( cronstrings timestamp -- entries )
    start-of-month dup end-of-month group-crons ;

: crons-for-year ( cronstrings timestamp -- entries )
    start-of-year dup end-of-year group-crons ;

: crons-for-decade ( cronstrings timestamp -- entries )
    start-of-decade dup end-of-decade group-crons ;

: crons-this-minute ( cronstrings -- entries ) now crons-for-minute ;
: crons-this-hour ( cronstrings -- entries ) now crons-for-hour ;
: crons-this-day ( cronstrings -- entries ) now crons-for-day ;
ALIAS: crons-today crons-this-day
: crons-yesterday ( cronstrings -- entries ) 1 days ago crons-for-day ;
: crons-tomorrow ( cronstrings -- entries ) 1 days hence crons-for-day ;
: crons-this-week ( cronstrings -- entries ) now crons-for-week ;
: crons-this-month ( cronstrings -- entries ) now crons-for-month ;
: crons-this-year ( cronstrings -- entries ) now crons-for-year ;
: crons-this-decade ( cronstrings -- entries ) now crons-for-decade ;

: keys-unix-to-rfc822 ( assoc -- assoc' )
    [ unix-time>timestamp timestamp>rfc822 ] map-keys ;

: keys-rfc822-to-unix ( assoc -- assoc' )
    [ rfc822>timestamp timestamp>unix-time ] map-keys ;

: grouped-crons. ( assoc -- )
    keys-unix-to-rfc822 [ first2 [ write bl ] [ ... ] bi* ] each ;
