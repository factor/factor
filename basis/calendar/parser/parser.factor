! Copyright (C) 2008, 2010 Slava Pestov, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs calendar calendar.english combinators
continuations generalizations io io.streams.string kernel macros math
math.functions math.parser sequences ;
IN: calendar.parser

: read-00 ( -- n ) 2 read string>number ;

: read-000 ( -- n ) 3 read string>number ;

: read-0000 ( -- n ) 4 read string>number ;

: expect ( str -- )
    read1 swap member? [ "Parse error" throw ] unless ;

ERROR: invalid-timestamp-format ;

: check-timestamp ( obj/f -- obj )
    [ invalid-timestamp-format ] unless* ;

: checked-number ( str -- n )
    string>number check-timestamp ;

: read-token ( seps -- token )
    [ read-until ] keep member? check-timestamp drop ;

: read-sp ( -- token ) " " read-token ;

: signed-gmt-offset ( dt ch -- dt' )
    { { CHAR: + [ 1 ] } { CHAR: - [ -1 ] } } case time* ;

: read-rfc3339-gmt-offset ( ch -- dt )
    {
        { f [ instant ] }
        { CHAR: Z [ instant ] }
        [
            [
                read-00 hours
                read1 { { CHAR: : [ read-00 ] } { f [ 0 ] } } case minutes
                time+
            ] dip signed-gmt-offset
        ]
    } case ;

: read-ymd ( -- y m d )
    read-0000 "-" expect read-00 "-" expect read-00 ;

: read-hms ( -- h m s )
    read-00 ":" expect read-00 ":" expect read-00 ;

: read-rfc3339-seconds ( s -- s' ch )
    "+-Z" read-until [
        [ string>number ] [ length 10^ ] bi / +
    ] dip ;

: (rfc3339>timestamp) ( -- timestamp )
    read-ymd
    "Tt \t" expect
    read-hms
    read1 { { CHAR: . [ read-rfc3339-seconds ] } [ ] } case
    read-rfc3339-gmt-offset
    <timestamp> ;

: rfc3339>timestamp ( str -- timestamp )
    [ (rfc3339>timestamp) ] with-string-reader ;

: parse-rfc822-military-offset ( string -- dt )
    first CHAR: A - {
        -1 -2 -3 -4 -5 -6 -7 -8 -9 f -10 -11 -12
        1 2 3 4 5 6 7 8 9 10 11 12 0
    } nth hours ;

CONSTANT: rfc822-named-zones H{
    { "EST" -5 }
    { "EDT" -4 }
    { "CST" -6 }
    { "CDT" -5 }
    { "MST" -7 }
    { "MDT" -6 }
    { "PST" -8 }
    { "PDT" -7 }
}

: parse-rfc822-gmt-offset ( string -- dt )
    {
        { [ dup { "UTC" "GMT" } member? ] [ drop instant ] }
        { [ dup length 1 = ] [ parse-rfc822-military-offset ] }
        { [ dup rfc822-named-zones key? ] [ rfc822-named-zones at hours ] }
        [
            unclip [
                2 cut [ string>number ] bi@ [ hours ] [ minutes ] bi* time+
            ] dip signed-gmt-offset
        ]
    } cond ;

: read-hh:mm:ss ( -- hh mm ss )
    ":" read-token checked-number
    ":" read-token checked-number
    read-sp checked-number ;

: (rfc822>timestamp) ( -- timestamp )
    "," read-token day-abbreviations3 member? check-timestamp drop
    read1 CHAR: \s assert=
    read-sp checked-number
    read-sp month-abbreviations index 1 + check-timestamp
    read-sp checked-number spin
    read-hh:mm:ss
    " " read-until drop parse-rfc822-gmt-offset <timestamp> ;

: rfc822>timestamp ( str -- timestamp )
    [ (rfc822>timestamp) ] with-string-reader ;

: check-day-name ( str -- )
    [ day-abbreviations3 member? ] [ day-names member? ] bi or
    check-timestamp drop ;

: (cookie-string>timestamp-1) ( -- timestamp )
    "," read-token check-day-name
    read1 CHAR: \s assert=
    "-" read-token checked-number
    "-" read-token month-abbreviations index 1 + check-timestamp
    read-sp checked-number spin
    read-hh:mm:ss
    " " read-until drop parse-rfc822-gmt-offset <timestamp> ;

: cookie-string>timestamp-1 ( str -- timestamp )
    [ (cookie-string>timestamp-1) ] with-string-reader ;

: (cookie-string>timestamp-2) ( -- timestamp )
    read-sp check-day-name
    read-sp month-abbreviations index 1 + check-timestamp
    read-sp checked-number
    read-hh:mm:ss
    [ read-sp checked-number ] 5 ndip
    " " read-until drop parse-rfc822-gmt-offset <timestamp> ;

: cookie-string>timestamp-2 ( str -- timestamp )
    [ (cookie-string>timestamp-2) ] with-string-reader ;

MACRO: attempt-all-quots ( quots -- quot )
    dup length 1 = [ first ] [
        unclip swap
        [ nip attempt-all-quots ] curry
        [ recover ] 2curry
    ] if ;

: cookie-string>timestamp ( str -- timestamp )
    {
        [ cookie-string>timestamp-1 ]
        [ cookie-string>timestamp-2 ]
        [ rfc822>timestamp ]
    } attempt-all-quots ;

: (ymdhms>timestamp) ( -- timestamp )
    read-ymd " " expect read-hms instant <timestamp> ;

: ymdhms>timestamp ( str -- timestamp )
    [ (ymdhms>timestamp) ] with-string-reader ;

: (ymd>timestamp) ( -- timestamp )
    read-ymd <date-gmt> ;

: ymd>timestamp ( str -- timestamp )
    [ (ymd>timestamp) ] with-string-reader ;

! Duration parsing
: hhmm>duration ( hhmm -- duration )
    [ instant read-00 >>hour read-00 >>minute ] with-string-reader ;

: hms>duration ( str -- duration )
    [ 0 0 0 read-hms <duration> ] with-string-reader ;
