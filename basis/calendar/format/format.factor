! Copyright (C) 2008, 2010 Slava Pestov, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays calendar calendar.english combinators io
io.streams.string kernel math math.parser math.parser.private
present quotations sequences words ;
IN: calendar.format

MACRO: formatted ( spec -- quot )
    [
        {
            { [ dup word? ] [ 1quotation ] }
            { [ dup quotation? ] [ ] }
            [ [ nip write ] curry [ ] like ]
        } cond
    ] map [ cleave ] curry ;

: pad-00 ( n -- str ) number>string 2 CHAR: 0 pad-head ;

: pad-0000 ( n -- str ) number>string 4 CHAR: 0 pad-head ;

: write-00 ( n -- ) pad-00 write ;

: write-0000 ( n -- ) pad-0000 write ;

: hh ( timestamp -- ) hour>> write-00 ;

: mm ( timestamp -- ) minute>> write-00 ;

: ss ( timestamp -- ) second>> >integer write-00 ;

! Should be enough for anyone, allows to not do a fancy
! algorithm to detect infinite decimals (e.g 1/3)
: ss.SSSSSS ( timestamp -- )
    second>> >float "0" 9 6 "f" "C" format-float write ;

: hhmm ( timestamp -- ) [ hh ] [ mm ] bi ;

: hh:mm ( timestamp -- ) { hh ":" mm } formatted ;

: hh:mm:ss ( timestamp -- ) { hh ":" mm ":" ss } formatted ;

: hh:mm:ss.SSSSSS ( timestamp -- ) { hh ":" mm ":" ss.SSSSSS } formatted ;

: D ( timestamp -- ) day>> number>string write ;

: DD ( timestamp -- ) day>> write-00 ;

: DAY ( timestamp -- ) day-of-week day-abbreviation3 write ;

: MM ( timestamp -- ) month>> write-00 ;

: MONTH ( timestamp -- ) month>> month-abbreviation write ;

: YYYY ( timestamp -- ) year>> write-0000 ;

: YYYY-MM-DD ( timestamp -- ) { YYYY "-" MM "-" DD } formatted ;

GENERIC: day. ( obj -- )

M: integer day.
    number>string dup length 2 < [ bl ] when write ;

M: timestamp day.
    day>> day. ;

GENERIC: month. ( obj -- )

M: array month.
    first2
    [ month-name write bl number>string print ]
    [ 1 zeller-congruence ]
    [ (days-in-month) day-abbreviations2 " " join print ] 2tri
    over "   " <repetition> "" concat-as write
    [
        [ 1 + day. ] keep
        1 + + 7 mod zero? [ nl ] [ bl ] if
    ] with each-integer nl ;

M: timestamp month.
    [ year>> ] [ month>> ] bi 2array month. ;

GENERIC: year. ( obj -- )

M: integer year.
    12 [ 1 + 2array month. nl ] with each-integer ;

M: timestamp year. year>> year. ;

: timestamp>mdtm ( timestamp -- str )
    [ { YYYY MM DD hh mm ss } formatted ] with-string-writer ;

: timestamp>ymd ( timestamp -- str )
    [ YYYY-MM-DD ] with-string-writer ;

: timestamp>hms ( timestamp -- str )
    [ hh:mm:ss ] with-string-writer ;

: timestamp>ymdhms ( timestamp -- str )
    [ >gmt YYYY-MM-DD " " hh:mm:ss ] with-string-writer ;

: write-gmt-offset-hhmm ( gmt-offset -- )
    [ hour>> dup 0 < "-" "+" ? write abs write-00 ] [ mm ] bi ;

: write-gmt-offset-hh:mm ( gmt-offset -- )
    [ hour>> dup 0 < "-" "+" ? write abs write-00 ":" write ] [ mm ] bi ;

: write-gmt-offset ( gmt-offset -- )
    dup instant = [ drop "GMT" write ] [ write-gmt-offset-hhmm ] if ;

: write-gmt-offset-z ( gmt-offset -- )
    dup instant = [ drop "Z" write ] [ write-gmt-offset-hh:mm ] if ;

: write-rfc1036 ( timestamp -- )
    {
        DAY ", " DD "-" MONTH "-" YYYY " " hh ":" mm ":" ss " "
        [ gmt-offset>> write-gmt-offset ]
    } formatted ;

: timestamp>rfc1036 ( timestamp -- str )
    [ write-rfc1036 ] with-string-writer ;

! RFC850 obsoleted by RFC1036
ALIAS: write-rfc850 write-rfc1036
ALIAS: timestamp>rfc850 timestamp>rfc1036

: write-rfc2822 ( timestamp -- )
    {
        DAY ", " D " " MONTH " " YYYY " " hh ":" mm ":" ss " "
        [ gmt-offset>> write-gmt-offset ]
    } formatted ;

: timestamp>rfc2822 ( timestamp -- str )
    [ write-rfc2822 ] with-string-writer ;

! RFC822 obsoleted by RFC2822
ALIAS: write-rfc822 write-rfc2822
ALIAS: timestamp>rfc822 timestamp>rfc2822

: write-rfc3339 ( timestamp -- )
    {
        YYYY "-" MM "-" DD "T" hh ":" mm ":" ss.SSSSSS
        [ gmt-offset>> write-gmt-offset-z ]
    } formatted ;

: timestamp>rfc3339 ( timestamp -- str )
    [ write-rfc3339 ] with-string-writer ;

: write-iso8601 ( timestamp -- )
    {
        YYYY "-" MM "-" DD "T" hh ":" mm ":" ss.SSSSSS
        [ gmt-offset>> write-gmt-offset-hh:mm ]
    } formatted ;

: timestamp>iso8601 ( timestamp -- str )
    [ write-iso8601 ] with-string-writer ;

: timestamp>git-string ( timestamp -- str )
    [
        {
            DAY " " MONTH " " D " " hh ":" mm ":" ss " " YYYY " "
            [ gmt-offset>> write-gmt-offset-hhmm ]
        } formatted
    ] with-string-writer ;

: timestamp>http-string ( timestamp -- str )
    >gmt timestamp>rfc2822 ;

: timestamp>cookie-string ( timestamp -- str )
    >gmt timestamp>rfc1036 ;

: timestamp>string ( timestamp -- str )
    [
        { DAY ", " D " " MONTH " " YYYY " " hh ":" mm ":" ss } formatted
    ] with-string-writer ;

M: timestamp present timestamp>string ;

: duration>hm ( duration -- str )
    [ duration>hours >integer 24 mod pad-00 ]
    [ duration>minutes >integer 60 mod pad-00 ] bi ":" glue ;

: duration>hms ( duration -- str )
    [ duration>hm ] [ second>> >integer 60 mod pad-00 ] bi ":" glue ;

: duration>human-readable ( duration -- string )
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
