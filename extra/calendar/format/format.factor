IN: calendar.format
USING: math math.parser kernel sequences io calendar
accessors arrays io.streams.string combinators ;

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

: write-00 pad-00 write ;

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

: (write-gmt-offset) ( ratio -- )
    1 /mod swap write-00 60 * write-00 ;

: write-gmt-offset ( gmt-offset -- )
    {
        { [ dup zero? ] [ drop "GMT" write ] }
        { [ dup 0 < ] [ "-" write neg (write-gmt-offset) ] }
        { [ dup 0 > ] [ "+" write (write-gmt-offset) ] }
    } cond ;

: timestamp>rfc822-string ( timestamp -- str )
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
    >gmt timestamp>rfc822-string ;

: write-rfc3339-gmt-offset ( n -- )
    dup zero? [ drop "Z" write ] [
        dup 0 < [ CHAR: - write1 neg ] [ CHAR: + write1 ] if
        60 * 60 /mod swap write-00 CHAR: : write1 write-00
    ] if ;

: (timestamp>rfc3339) ( timestamp -- )
    dup year>> number>string write CHAR: - write1
    dup month>> write-00 CHAR: - write1
    dup day>> write-00 CHAR: T write1
    dup hour>> write-00 CHAR: : write1
    dup minute>> write-00 CHAR: : write1
    dup second>> >fixnum write-00
    gmt-offset>> write-rfc3339-gmt-offset ;

: timestamp>rfc3339 ( timestamp -- str )
    [ (timestamp>rfc3339) ] with-string-writer ;

: expect ( str -- )
    read1 swap member? [ "Parse error" throw ] unless ;

: read-00 2 read string>number ;

: read-0000 4 read string>number ;

: read-rfc3339-gmt-offset ( -- n )
    read1 dup CHAR: Z = [ drop 0 ] [
        { { CHAR: + [ 1 ] } { CHAR: - [ -1 ] } } case
        read-00
        read1 { { CHAR: : [ read-00 ] } { f [ 0 ] } } case
        60 / + *
    ] if ;

: (rfc3339>timestamp) ( -- timestamp )
    read-0000 ! year
    "-" expect
    read-00 ! month
    "-" expect
    read-00 ! day
    "Tt" expect
    read-00 ! hour
    ":" expect
    read-00 ! minute
    ":" expect
    read-00 ! second
    read-rfc3339-gmt-offset ! timezone
    <timestamp> ;

: rfc3339>timestamp ( str -- timestamp )
    [ (rfc3339>timestamp) ] with-string-reader ;

: file-time-string ( timestamp -- string )
    [
        [ month>> month-abbreviations nth write ] keep bl
        [ day>> number>string 2 32 pad-left write ] keep bl
        dup now [ year>> ] 2apply = [
            [ hour>> write-00 ] keep ":" write
            minute>> write-00
        ] [
            year>> number>string 5 32 pad-left write
        ] if
    ] with-string-writer ;
