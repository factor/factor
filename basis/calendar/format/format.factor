! Copyright (C) 2008, 2010 Slava Pestov, Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors calendar calendar.english combinators
formatting grouping io io.streams.string kernel make math
math.order math.parser math.parser.private ranges present
quotations sequences splitting strings words ;
IN: calendar.format

MACRO: formatted ( spec -- quot )
    [
        {
            { [ dup word? ] [ 1quotation ] }
            { [ dup quotation? ] [ ] }
            [ [ nip write ] curry ]
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

<PRIVATE

: center. ( str n -- )
    over length [-] 2/ CHAR: \s <string> write print ;

: month-header. ( year month -- )
    [ number>string ] [ month-name ] bi* swap " " glue 20 center. ;

: days-header. ( -- )
    day-abbreviations2 join-words print ;

: days. ( year month -- )
    [ 1 (day-of-week) dup [ "   " write ] times ]
    [ (days-in-month) ] 2bi [1..b] [
        [ day. ] [ + 7 mod zero? [ nl ] [ bl ] if ] bi
    ] with each nl ;

PRIVATE>

: month. ( timestamp -- )
    [ year>> ] [ month>> ] bi
    [ month-header. ] [ days-header. days. ] 2bi ;

GENERIC: year. ( obj -- )

M: integer year.
    dup number>string 64 center. nl 12 [1..b] [
        [
            [ month-name 20 center. ]
            [ days-header. days. nl nl ] bi
        ] with-string-writer split-lines
    ] with map 3 <groups>
    [ first3 [ "%-20s  %-20s  %-20s\n" printf ] 3each ] each ;

M: timestamp year. year>> year. ;

: timestamp>mdtm ( timestamp -- str )
    [ { YYYY MM DD hh mm ss } formatted ] with-string-writer ;

: timestamp>ymd ( timestamp -- str )
    [ YYYY-MM-DD ] with-string-writer ;

: timestamp>hms ( timestamp -- str )
    [ hh:mm:ss ] with-string-writer ;

: timestamp>ymdhms ( timestamp -- str )
    [ >gmt { YYYY-MM-DD " " hh:mm:ss } formatted ] with-string-writer ;

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
        DAY ", " DD "-" MONTH "-" YYYY " " hh:mm:ss " "
        [ gmt-offset>> write-gmt-offset ]
    } formatted ;

: timestamp>rfc1036 ( timestamp -- str )
    [ write-rfc1036 ] with-string-writer ;

! RFC850 obsoleted by RFC1036
ALIAS: write-rfc850 write-rfc1036
ALIAS: timestamp>rfc850 timestamp>rfc1036

: write-rfc2822 ( timestamp -- )
    {
        DAY ", " D " " MONTH " " YYYY " " hh:mm:ss " "
        [ gmt-offset>> write-gmt-offset ]
    } formatted ;

: timestamp>rfc2822 ( timestamp -- str )
    [ write-rfc2822 ] with-string-writer ;

! RFC822 obsoleted by RFC2822
ALIAS: write-rfc822 write-rfc2822
ALIAS: timestamp>rfc822 timestamp>rfc2822

: write-rfc3339 ( timestamp -- )
    {
        YYYY-MM-DD "T" hh:mm:ss.SSSSSS
        [ gmt-offset>> write-gmt-offset-z ]
    } formatted ;

: timestamp>rfc3339 ( timestamp -- str )
    [ write-rfc3339 ] with-string-writer ;

: write-iso8601 ( timestamp -- )
    {
        YYYY-MM-DD "T" hh:mm:ss.SSSSSS
        [ gmt-offset>> write-gmt-offset-hh:mm ]
    } formatted ;

: timestamp>iso8601 ( timestamp -- str )
    [ write-iso8601 ] with-string-writer ;

: write-ctime ( timestamp -- )
    {
        DAY " " MONTH " " DD " " hh:mm:ss " " YYYY
    } formatted ;

: timestamp>ctime-string ( timestamp -- str )
    [ write-ctime ] with-string-writer ;

: timestamp>git-string ( timestamp -- str )
    [
        {
            DAY " " MONTH " " D " " hh:mm:ss " " YYYY " "
            [ gmt-offset>> write-gmt-offset-hhmm ]
        } formatted
    ] with-string-writer ;

: timestamp>http-string ( timestamp -- str )
    >gmt timestamp>rfc2822 ;

: timestamp>cookie-string ( timestamp -- str )
    >gmt timestamp>rfc1036 ;

: write-timestamp ( timestamp -- )
    { DAY ", " D " " MONTH " " YYYY " " hh:mm:ss } formatted ;

: timestamp>string ( timestamp -- str )
    [ write-timestamp ] with-string-writer ;

M: timestamp present timestamp>string ;

: duration>hm ( duration -- str )
    [ duration>hours >integer 24 mod pad-00 ]
    [ duration>minutes >integer 60 mod pad-00 ] bi ":" glue ;

: duration>hms ( duration -- str )
    [ duration>hm ]
    [ duration>seconds >integer 60 mod pad-00 ] bi ":" glue ;

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

GENERIC: elapsed-time ( seconds -- string )

M: integer elapsed-time
    dup 0 < [ "negative seconds" throw ] when [
        {
            { 60 "s" }
            { 60 "m" }
            { 24 "h" }
            {  7 "d" }
            { 52 "w" }
            {  f "y" }
        } [
            [ first [ /mod ] [ dup ] if* ] [ second ] bi swap
            dup 0 > [ number>string prepend , ] [ 2drop ] if
        ] each drop
    ] { } make [ "0s" ] [ reverse join-words ] if-empty ;

M: real elapsed-time
    >integer elapsed-time ;

M: duration elapsed-time
    duration>seconds elapsed-time ;

M: timestamp elapsed-time
    ago elapsed-time ;

! XXX: Anything up to 2 hours is "about an hour"
: relative-time-offset ( seconds -- string )
    abs {
        { [ dup 1 < ] [ drop "just now" ] }
        { [ dup 60 < ] [ drop "less than a minute" ] }
        { [ dup 120 < ] [ drop "about a minute" ] }
        { [ dup 2700 < ] [ 60 /i "%d minutes" sprintf ] }
        { [ dup 7200 < ] [ drop "about an hour" ] }
        { [ dup 86400 < ] [ 3600 /i "%d hours" sprintf ] }
        { [ dup 172800 < ] [ drop "1 day" ] }
        [ 86400 /i "%d days" sprintf ]
    } cond ;

GENERIC: relative-time ( seconds -- string )

M: real relative-time
    [ relative-time-offset ] [
        dup abs 1 < [
            drop
        ] [
            0 < "hence" "ago" ? " " glue
        ] if
    ] bi ;

M: duration relative-time
    duration>seconds relative-time ;

M: timestamp relative-time
    ago relative-time ;
