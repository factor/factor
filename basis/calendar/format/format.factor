! Copyright (C) 2008, 2010 Slava Pestov, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays calendar calendar.english combinators
fry io io.streams.string kernel macros math math.order
math.parser math.parser.private present quotations sequences
typed words ;
IN: calendar.format

MACRO: formatted ( spec -- quot )
    [
        {
            { [ dup word? ] [ 1quotation ] }
            { [ dup quotation? ] [ ] }
            [ [ nip write ] curry [ ] like ]
        } cond
    ] map [ cleave ] curry ;

: formatted>string ( spec -- string )
    '[ _ formatted ] with-string-writer ; inline

: pad-00 ( n -- str ) number>string 2 CHAR: 0 pad-head ;

: pad-0000 ( n -- str ) number>string 4 CHAR: 0 pad-head ;

: pad-00000 ( n -- str ) number>string 5 CHAR: 0 pad-head ;

: write-00 ( n -- ) pad-00 write ;

: write-0000 ( n -- ) pad-0000 write ;

: write-00000 ( n -- ) pad-00000 write ;

: hh ( time -- ) hour>> write-00 ;

: mm ( time -- ) minute>> write-00 ;

: ss ( time -- ) second>> >integer write-00 ;

: D ( time -- ) day>> number>string write ;

: DD ( time -- ) day>> write-00 ;

: DAY ( time -- ) day-of-week day-abbreviation3 write ;

: MM ( time -- ) month>> write-00 ;

: MONTH ( time -- ) month>> month-abbreviation write ;

: YYYY ( time -- ) year>> write-0000 ;

: YYYYY ( time -- ) year>> write-00000 ;

GENERIC: day. ( obj -- )

M: integer day. ( n -- )
    number>string dup length 2 < [ bl ] when write ;

M: timestamp day. ( timestamp -- )
    day>> day. ;

GENERIC: month. ( obj -- )

M: array month. ( pair -- )
    first2
    [ month-name write bl number>string print ]
    [ 1 zeller-congruence ]
    [ (days-in-month) day-abbreviations2 " " join print ] 2tri
    over "   " <repetition> "" concat-as write
    [
        [ 1 + day. ] keep
        1 + + 7 mod zero? [ nl ] [ bl ] if
    ] with each-integer nl ;

M: timestamp month. ( timestamp -- )
    [ year>> ] [ month>> ] bi 2array month. ;

GENERIC: year. ( obj -- )

M: integer year. ( n -- )
    12 [ 1 + 2array month. nl ] with each-integer ;

M: timestamp year. ( timestamp -- )
    year>> year. ;

: timestamp>mdtm ( timestamp -- str )
    [ { YYYY MM DD hh mm ss } formatted ] with-string-writer ;

: (timestamp>string) ( timestamp -- )
    { DAY ", " D " " MONTH " " YYYY " " hh ":" mm ":" ss } formatted ;

: timestamp>string ( timestamp -- str )
    [ (timestamp>string) ] with-string-writer ;

: write-hhmm ( duration -- )
    [ hh ] [ mm ] bi ;

: write-gmt-offset ( gmt-offset -- )
    dup instant <=> {
        { +eq+ [ drop "GMT" write ] }
        { +lt+ [ "-" write before write-hhmm ] }
        { +gt+ [ "+" write write-hhmm ] }
    } case ;

: write-gmt-offset-number ( gmt-offset -- )
    dup instant <=> {
        { +eq+ [ drop "+0000" write ] }
        { +lt+ [ "-" write before write-hhmm ] }
        { +gt+ [ "+" write write-hhmm ] }
    } case ;

: timestamp>rfc822 ( timestamp -- str )
    ! RFC822 timestamp format
    ! Example: Tue, 15 Nov 1994 08:12:31 +0200
    [
        [ (timestamp>string) bl ]
        [ gmt-offset>> write-gmt-offset ]
        bi
    ] with-string-writer ;

: timestamp>git-time ( timestamp -- str )
    [
        [ { DAY " " MONTH " " D " " hh ":" mm ":" ss " " YYYY " " } formatted ]
        [ gmt-offset>> write-gmt-offset-number ] bi
    ] with-string-writer ;

: timestamp>http-string ( timestamp -- str )
    ! http timestamp format
    ! Example: Tue, 15 Nov 1994 08:12:31 GMT
    >gmt timestamp>rfc822 ;

: (timestamp>cookie-string) ( timestamp -- )
    >gmt
    { DAY ", " DD "-" MONTH "-" YYYY " " hh ":" mm ":" ss " GMT" } formatted ;

: timestamp>cookie-string ( timestamp -- str )
    [ (timestamp>cookie-string) ] with-string-writer ;

: (write-rfc3339-gmt-offset) ( duration -- )
    [ hh ":" write ] [ mm ] bi ;

: write-rfc3339-gmt-offset ( duration -- )
    dup instant <=> {
        { +eq+ [ drop "Z" write ] }
        { +lt+ [ "-" write before (write-rfc3339-gmt-offset) ] }
        { +gt+ [ "+" write (write-rfc3339-gmt-offset) ] }
    } case ;

! Should be enough for anyone, allows to not do a fancy
! algorithm to detect infinite decimals (e.g 1/3)
: ss.SSSSSS ( timestamp -- )
    second>> >float "0" 9 6 "f" "C" format-float write ;

: (timestamp>rfc3339) ( timestamp -- )
    {
        YYYY "-" MM "-" DD "T" hh ":" mm ":" ss.SSSSSS
        [ gmt-offset>> write-rfc3339-gmt-offset ]
    } formatted ;

: timestamp>rfc3339 ( timestamp -- str )
    [ (timestamp>rfc3339) ] with-string-writer ;

: (timestamp>ymd) ( timestamp -- )
    { YYYY "-" MM "-" DD } formatted ;

TYPED: timestamp>ymd ( timestamp: timestamp -- str )
    [ (timestamp>ymd) ] with-string-writer ;

: (timestamp>hms) ( timestamp -- )
    { hh ":" mm ":" ss } formatted ;

TYPED: timestamp>hms ( timestamp: timestamp -- str )
    [ (timestamp>hms) ] with-string-writer ;

TYPED: timestamp>ymdhms ( timestamp: timestamp -- str )
    [
        >gmt
        { (timestamp>ymd) " " (timestamp>hms) } formatted
    ] with-string-writer ;

: file-time-string ( timestamp -- string )
    [
        {
            MONTH " " DD " "
            [
                dup now [ year>> ] same?
                [ [ hh ":" write ] [ mm ] bi ] [ YYYYY ] if
            ]
        } formatted
    ] with-string-writer ;

M: timestamp present timestamp>string ;

! Duration formatting
TYPED: duration>hm ( duration: duration -- str )
    [ duration>hours >integer 24 mod pad-00 ]
    [ duration>minutes >integer 60 mod pad-00 ] bi ":" glue ;

TYPED: duration>hms ( duration: duration -- str )
    [ duration>hm ] [ second>> >integer 60 mod pad-00 ] bi ":" glue ;

TYPED: duration>human-readable ( duration: duration -- string )
    [
        [
            duration>years >integer
            [
                [ number>string write ]
                [ 1 > " years, " " year, " ? write ] bi
            ] unless-zero
        ] [
            duration>days >integer 365 mod
            [
                [ number>string write ]
                [ 1 > " days, " " day, " ? write ] bi
            ] unless-zero
        ] [ duration>hms write ] tri
    ] with-string-writer ;
