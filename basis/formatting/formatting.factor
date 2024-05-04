! Copyright (C) 2008 John Benediktsson
! See https://factorcode.org/license.txt for BSD license
USING: accessors arrays assocs byte-arrays calendar
calendar.english calendar.private combinators combinators.smart
generalizations interpolate.private io io.streams.string kernel
math math.functions math.parser multiline namespaces peg.ebnf
present prettyprint quotations sequences
sequences.generalizations splitting strings unicode ;
IN: formatting

ERROR: unknown-format-directive value ;

<PRIVATE

PRIMITIVE: (format-float) ( n fill width precision format locale -- byte-array )

: pad-null ( format -- format )
    0 over length 1 + <byte-array> [ copy ] keep ; foldable

: format-float ( n fill width precision format locale -- string )
    [ pad-null ] 4dip [ pad-null ] bi@ (format-float) >string ; inline

: compose-all ( seq -- quot )
    [ ] [ compose ] reduce ; inline

: fix-sign ( string -- string )
    dup first CHAR: 0 = [
        dup [ [ CHAR: 0 = not ] [ digit? ] bi and ] find
        [
            1 - swap 2dup nth {
                { CHAR: - [ remove-nth "-" prepend ] }
                { CHAR: + [ remove-nth "+" prepend ] }
                [ drop nip ]
            } case
        ] [ drop ] if
    ] when ;

: >digits ( string -- digits )
    [ 0 ] [ string>number ] if-empty ;

: format-decimal-simple ( x digits -- string )
    [
        [ abs ] dip
        [ 10^ * round-to-even >integer number>string ]
        [ 1 + CHAR: 0 pad-head ]
        [ cut* ] tri [ "." glue ] unless-empty
    ] keepd neg? [ CHAR: - prefix ] when ;

: format-scientific-mantissa ( x log10x digits -- string rounded-up? )
    [ swap - 10^ * round-to-even >integer number>string ] keep
    over length 1 - < [
        [ but-last >string ] when ! 9.9 rounded to 1e+01
        1 cut [ "." glue ] unless-empty
    ] keep ;

: format-scientific-exponent ( rounded-up? log10x -- string )
    swap [ 1 + ] when number>string 2 CHAR: 0 pad-head
    dup CHAR: - swap index "e" "e+" ? prepend ;

: format-scientific-simple ( x digits -- string )
    [
        [ abs dup integer-log10 ] dip
        [ format-scientific-mantissa ]
        [ drop nip format-scientific-exponent ] 3bi append
    ] keepd neg? [ CHAR: - prefix ] when ;

: format-float-fast ( x digits string -- string )
    [ "" -1 ] 2dip "C" format-float ;

: format-fast-scientific? ( x digits -- x' digits ? )
    over float? [ t ]
    [ 2dup
        [ [ t ] [ abs integer-log10 abs 308 < ] if-zero ]
        [ 15 < ] bi* and
        [ [ [ >float ] dip ] when ] keep
    ] if ;

: format-scientific ( x digits -- string )
    format-fast-scientific?
    [ "e" format-float-fast ] [ format-scientific-simple ] if ;

: format-fast-decimal? ( x digits -- x' digits ? )
    over float? [ t ] [
        2dup
        [ drop dup integer?  [ abs 53 2^ < ] [ drop f ] if ]
        [ over ratio?
            [ [ abs integer-log10 ] dip
              [ drop abs 308 < ] [ + 15 <= ] 2bi and ]
            [ 2drop f ] if
        ] 2bi or
        [ [ [ >float ] dip ] when ] keep
    ] if ; inline

: format-decimal ( x digits -- string )
    format-fast-decimal?
    [ "f" format-float-fast ] [ format-decimal-simple ] if ;

EBNF: format-directive [=[

zero      = "0"                  => [[ CHAR: 0 ]]
char      = "'" (.)              => [[ second ]]

pad-char  = (zero|char)?         => [[ CHAR: \s or ]]
pad-align = ("-")?               => [[ \ pad-tail \ pad-head ? ]]
pad-width = ([0-9])*             => [[ >digits ]]
pad       = pad-align pad-char pad-width => [[ <reversed> >quotation dup first 0 = [ drop [ ] ] when ]]

sign_     = [+ ]                 => [[ '[ dup first CHAR: - = [ _ prefix ] unless ] ]]
sign      = (sign_)?             => [[ [ ] or ]]

width_    = "." ([0-9])*         => [[ second >digits '[ _ index-or-length head ] ]]
width     = (width_)?            => [[ [ ] or ]]

digits_   = "." ([0-9])*         => [[ second >digits ]]
digits    = (digits_)?           => [[ 6 or ]]

fmt-%     = "%"                  => [[ "%" ]]
fmt-c     = "c"                  => [[ [ 1string ] ]]
fmt-C     = "C"                  => [[ [ 1string >upper ] ]]
fmt-s     = "s"                  => [[ [ present ] ]]
fmt-S     = "S"                  => [[ [ present >upper ] ]]
fmt-u     = "u"                  => [[ [ unparse ] ]]
fmt-d     = "d"                  => [[ [ >integer number>string ] ]]
fmt-o     = "o"                  => [[ [ >integer >oct ] ]]
fmt-b     = "b"                  => [[ [ >integer >bin ] ]]
fmt-e     = digits "e"           => [[ first '[ _ format-scientific ] ]]
fmt-E     = digits "E"           => [[ first '[ _ format-scientific >upper ] ]]
fmt-f     = digits "f"           => [[ first '[ _ format-decimal ] ]]
fmt-x     = "x"                  => [[ [ >integer >hex ] ]]
fmt-X     = "X"                  => [[ [ >integer >hex >upper ] ]]
unknown   = (.)*                 => [[ "" like unknown-format-directive ]]

strings_  = fmt-c|fmt-C|fmt-s|fmt-S|fmt-u
strings   = pad width strings_   => [[ <reversed> compose-all ]]

numbers_  = fmt-d|fmt-o|fmt-b|fmt-e|fmt-E|fmt-f|fmt-x|fmt-X
numbers   = sign pad numbers_    => [[ unclip-last prefix compose-all [ fix-sign ] append ]]

types     = strings|numbers

lists     = "[%" types ", %]"    => [[ second '[ _ { } map-as ", " join "{ " " }" surround ] ]]

assocs    = "[%" types ": %" types " %]" => [[ [ second ] [ fourth ] bi '[ [ _ _ bi* ":" glue ] { } assoc>map ", " join "{ " " }" surround ] ]]

formats   = (types|fmt-%|lists|assocs|unknown)
]=]

SINGLETON: printf-formatter
printf-formatter formatter set-global

M: printf-formatter format
    [ [ present ] ] [ format-directive ] if-empty ;

EBNF: parse-printf [=[
formats   = "%"~ <foreign format-directive formats>
plain-text = [^%]+               => [[ >string ]]
text      = (formats|plain-text)*
]=]

: printf-quot ( format-string -- format-quot n )
    parse-printf [ [ callable? ] count ] keep [
        dup string? [ 1quotation ] [ [ 1 - ] dip ] if
        over [ ndip ] 2curry
    ] map nip [ compose-all ] [ length ] bi ; inline

PRIVATE>

MACRO: printf ( format-string -- quot )
    printf-quot '[
        @ output-stream get [ stream-write ] curry _ napply
    ] ;

MACRO: sprintf ( format-string -- quot )
    printf-quot '[
        @ _ "" nappend-as
    ] ;

: vprintf ( seq format-string -- )
    parse-printf output-stream get '[
        dup string? [
            [ unclip-slice ] dip call( x -- y )
        ] unless _ stream-write
    ] each drop ;

: vsprintf ( seq format-string -- result )
    [ vprintf ] with-string-writer ; inline

<PRIVATE

: pad-00 ( n -- string )
    number>string 2 CHAR: 0 pad-head ; inline

: pad-000 ( n -- string )
    number>string 3 CHAR: 0 pad-head ; inline

: >time ( timestamp -- string )
    [ hour>> ] [ minute>> ] [ second>> floor ] tri
    [ pad-00 ] tri@ 3array ":" join ; inline

: >date ( timestamp -- string )
    [ month>> ] [ day>> ] [ year>> ] tri
    [ pad-00 ] tri@ 3array "/" join ; inline

: >datetime ( timestamp -- string )
    [
       {
            [ day-of-week day-abbreviation3 ]
            [ month>> month-abbreviation ]
            [ day>> pad-00 ]
            [ >time ]
            [ year>> number>string ]
       } cleave
    ] output>array join-words ; inline

: week-of-year ( timestamp day -- n )
    [ dup clone first-day-of-year dup clone ]
    [ day-this-week ] bi* swap '[ _ time- duration>days ] bi@
    dup 0 < [ 7 + - ] [ drop ] if 7 + 7 /i ;

: week-of-year-sunday ( timestamp -- n ) 0 week-of-year ; inline

: week-of-year-monday ( timestamp -- n ) 1 week-of-year ; inline

EBNF: parse-strftime [=[

fmt-%     = "%"                  => [[ "%" ]]
fmt-a     = "a"                  => [[ [ day-of-week day-abbreviation3 ] ]]
fmt-A     = "A"                  => [[ [ day-of-week day-name ] ]]
fmt-b     = "b"                  => [[ [ month>> month-abbreviation ] ]]
fmt-B     = "B"                  => [[ [ month>> month-name ] ]]
fmt-c     = "c"                  => [[ [ >datetime ] ]]
fmt-d     = "d"                  => [[ [ day>> pad-00 ] ]]
fmt-H     = "H"                  => [[ [ hour>> pad-00 ] ]]
fmt-I     = "I"                  => [[ [ hour>> dup 12 > [ 12 - ] when pad-00 ] ]]
fmt-j     = "j"                  => [[ [ day-of-year pad-000 ] ]]
fmt-m     = "m"                  => [[ [ month>> pad-00 ] ]]
fmt-M     = "M"                  => [[ [ minute>> pad-00 ] ]]
fmt-p     = "p"                  => [[ [ hour>> 12 < "AM" "PM" ? ] ]]
fmt-S     = "S"                  => [[ [ second>> floor pad-00 ] ]]
fmt-U     = "U"                  => [[ [ week-of-year-sunday pad-00 ] ]]
fmt-w     = "w"                  => [[ [ day-of-week number>string ] ]]
fmt-W     = "W"                  => [[ [ week-of-year-monday pad-00 ] ]]
fmt-x     = "x"                  => [[ [ >date ] ]]
fmt-X     = "X"                  => [[ [ >time ] ]]
fmt-y     = "y"                  => [[ [ year>> 100 mod pad-00 ] ]]
fmt-Y     = "Y"                  => [[ [ year>> number>string ] ]]
fmt-Z     = "Z"                  => [[ [ "Not yet implemented" throw ] ]]
unknown   = (.)*                 => [[ "" like unknown-format-directive ]]

formats_  = fmt-%|fmt-a|fmt-A|fmt-b|fmt-B|fmt-c|fmt-d|fmt-H|fmt-I|
            fmt-j|fmt-m|fmt-M|fmt-p|fmt-S|fmt-U|fmt-w|fmt-W|fmt-x|
            fmt-X|fmt-y|fmt-Y|fmt-Z|unknown

formats   = "%" (formats_)       => [[ second ]]

plain-text = [^%]+               => [[ >string ]]

text      = (formats|plain-text)*

]=]

PRIVATE>

MACRO: strftime ( format-string -- quot )
    parse-strftime [
        dup string? [
            '[ _ append! ]
        ] [
            '[ over @ append! ]
        ] if
    ] map concat '[ SBUF" " clone @ nip "" like ] ;
