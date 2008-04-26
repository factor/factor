USING: math math.parser kernel sequences io calendar
accessors arrays io.streams.string splitting math.order
combinators accessors debugger ;
IN: calendar.format

GENERIC: day. ( obj -- )

M: integer day. ( n -- )
    number>string dup length 2 < [ bl ] when write ;

M: timestamp day. ( timestamp -- )
    day>> day. ;

GENERIC: month. ( obj -- )

M: array month. ( pair -- )
    first2
    [ month-names nth write bl number>string print ] 2keep
    [ 1 zeller-congruence ] 2keep
    2array days-in-month day-abbreviations2 " " join print
    over "   " <repetition> concat write
    [
        [ 1+ day. ] keep
        1+ + 7 mod zero? [ nl ] [ bl ] if
    ] with each nl ;

M: timestamp month. ( timestamp -- )
    { year>> month>> } get-slots 2array month. ;

GENERIC: year. ( obj -- )

M: integer year. ( n -- )
    12 [ 1+ 2array month. nl ] with each ;

M: timestamp year. ( timestamp -- )
    year>> year. ;

: pad-00 number>string 2 CHAR: 0 pad-left ;

: pad-0000 number>string 4 CHAR: 0 pad-left ;

: write-00 pad-00 write ;

: write-0000 pad-0000 write ;

: (timestamp>string) ( timestamp -- )
    dup day-of-week day-abbreviations3 nth write ", " write
    dup day>> number>string write bl
    dup month>> month-abbreviations nth write bl
    dup year>> number>string write bl
    dup hour>> write-00 ":" write
    dup minute>> write-00 ":" write
    second>> >integer write-00 ;

: timestamp>string ( timestamp -- str )
    [ (timestamp>string) ] with-string-writer ;

: (write-gmt-offset) ( duration -- )
    [ hour>> write-00 ] [ minute>> write-00 ] bi ;

: write-gmt-offset ( gmt-offset -- )
    dup instant <=> sgn {
        {  0 [ drop "GMT" write ] }
        { -1 [ "-" write before (write-gmt-offset) ] }
        {  1 [ "+" write (write-gmt-offset) ] }
    } case ;

: timestamp>rfc822 ( timestamp -- str )
    #! RFC822 timestamp format
    #! Example: Tue, 15 Nov 1994 08:12:31 +0200
    [
        dup (timestamp>string)
        " " write
        gmt-offset>> write-gmt-offset
    ] with-string-writer ;

: timestamp>http-string ( timestamp -- str )
    #! http timestamp format
    #! Example: Tue, 15 Nov 1994 08:12:31 GMT
    >gmt timestamp>rfc822 ;

: (write-rfc3339-gmt-offset) ( duration -- )
    [ hour>> write-00 CHAR: : write1 ]
    [ minute>> write-00 ] bi ;

: write-rfc3339-gmt-offset ( duration -- )
    dup instant <=> sgn {
        {  0 [ drop "Z" write ] }
        { -1 [ CHAR: - write1 before (write-rfc3339-gmt-offset) ] }
        {  1 [ CHAR: + write1 (write-rfc3339-gmt-offset) ] }
    } case ;
    
: (timestamp>rfc3339) ( timestamp -- )
    {
        [ year>> number>string write CHAR: - write1 ]
        [ month>> write-00 CHAR: - write1 ]
        [ day>> write-00 CHAR: T write1 ]
        [ hour>> write-00 CHAR: : write1 ]
        [ minute>> write-00 CHAR: : write1 ]
        [ second>> >fixnum write-00 ]
        [ gmt-offset>> write-rfc3339-gmt-offset ]
    } cleave ;

: timestamp>rfc3339 ( timestamp -- str )
    [ (timestamp>rfc3339) ] with-string-writer ;

: expect ( str -- )
    read1 swap member? [ "Parse error" throw ] unless ;

: read-00 2 read string>number ;

: read-000 3 read string>number ;

: read-0000 4 read string>number ;

: signed-gmt-offset ( dt ch -- dt' )
    { { CHAR: + [ 1 ] } { CHAR: - [ -1 ] } } case time* ;

: read-rfc3339-gmt-offset ( ch -- dt )
    dup CHAR: Z = [ drop instant ] [
        >r
        read-00 hours
        read1 { { CHAR: : [ read-00 ] } { f [ 0 ] } } case minutes
        time+
        r> signed-gmt-offset
    ] if ;

: read-ymd ( -- y m d )
    read-0000 "-" expect read-00 "-" expect read-00 ;

: read-hms ( -- h m s )
    read-00 ":" expect read-00 ":" expect read-00 ;

: (rfc3339>timestamp) ( -- timestamp )
    read-ymd
    "Tt" expect
    read-hms
    read1 { { CHAR: . [ read-000 1000 / + read1 ] } [ ] } case
    read-rfc3339-gmt-offset
    <timestamp> ;

: rfc3339>timestamp ( str -- timestamp )
    [ (rfc3339>timestamp) ] with-string-reader ;

ERROR: invalid-rfc822-date ;

: check-rfc822-date ( obj/f -- obj ) [ invalid-rfc822-date ] unless* ;

: read-token ( seps -- token )
    [ read-until ] keep member? check-rfc822-date drop ;

: read-sp ( -- token ) " " read-token ;

: checked-number ( str -- n )
    string>number check-rfc822-date ;

: parse-rfc822-gmt-offset ( string -- dt )
    dup "GMT" = [ drop instant ] [
        unclip >r
        2 cut [ string>number ] bi@ [ hours ] [ minutes ] bi* time+
        r> signed-gmt-offset
    ] if ;

: (rfc822>timestamp) ( -- timestamp )
    timestamp new
        "," read-token day-abbreviations3 member? check-rfc822-date drop
        read1 CHAR: \s assert=
        read-sp checked-number >>day
        read-sp month-abbreviations index check-rfc822-date >>month
        read-sp checked-number >>year
        ":" read-token checked-number >>hour
        ":" read-token checked-number >>minute
        " " read-token checked-number >>second
        readln parse-rfc822-gmt-offset >>gmt-offset ;

: rfc822>timestamp ( str -- timestamp )
    [ (rfc822>timestamp) ] with-string-reader ;

: (ymdhms>timestamp) ( -- timestamp )
    read-ymd " " expect read-hms instant <timestamp> ;

: ymdhms>timestamp ( str -- timestamp )
    [ (ymdhms>timestamp) ] with-string-reader ;

: (hms>timestamp) ( -- timestamp )
    f f f read-hms instant <timestamp> ;

: hms>timestamp ( str -- timestamp )
    [ (hms>timestamp) ] with-string-reader ;

: (ymd>timestamp) ( -- timestamp )
    read-ymd f f f instant <timestamp> ;

: ymd>timestamp ( str -- timestamp )
    [ (ymd>timestamp) ] with-string-reader ;

: (timestamp>ymd) ( timestamp -- )
    dup timestamp-year write-0000
    "-" write
    dup timestamp-month write-00
    "-" write
    timestamp-day write-00 ;

: timestamp>ymd ( timestamp -- str )
    [ (timestamp>ymd) ] with-string-writer ;

: (timestamp>hms)
    dup timestamp-hour write-00
    ":" write
    dup timestamp-minute write-00
    ":" write
    timestamp-second >integer write-00 ;

: timestamp>hms ( timestamp -- str )
    [ (timestamp>hms) ] with-string-writer ;

: timestamp>ymdhms ( timestamp -- str )
    >gmt
    [
        dup (timestamp>ymd)
        " " write
        (timestamp>hms)
    ] with-string-writer ;

: file-time-string ( timestamp -- string )
    [
        [ month>> month-abbreviations nth write ] keep bl
        [ day>> number>string 2 32 pad-left write ] keep bl
        dup now [ year>> ] bi@ = [
            [ hour>> write-00 ] keep ":" write
            minute>> write-00
        ] [
            year>> number>string 5 32 pad-left write
        ] if
    ] with-string-writer ;
