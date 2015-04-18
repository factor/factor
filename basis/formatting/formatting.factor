! Copyright (C) 2008 John Benediktsson
! See http://factorcode.org/license.txt for BSD license
USING: accessors arrays assocs calendar combinators
combinators.smart fry generalizations io io.streams.string
kernel macros math math.functions math.parser namespaces
peg.ebnf present prettyprint quotations sequences strings
unicode.case unicode.categories vectors ;
FROM: math.parser.private => format-float ;
IN: formatting

<PRIVATE

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

: format-simple ( x digits string -- string )
    [ [ >float ] [ number>string ] bi* "%." ] dip
    surround format-float ;

: format-scientific ( x digits -- string ) "e" format-simple ;

: format-decimal ( x digits -- string ) "f" format-simple ;

ERROR: unknown-printf-directive ;

EBNF: parse-printf

zero      = "0"                  => [[ CHAR: 0 ]]
char      = "'" (.)              => [[ second ]]

pad-char  = (zero|char)?         => [[ CHAR: \s or ]]
pad-align = ("-")?               => [[ \ pad-tail \ pad-head ? ]]
pad-width = ([0-9])*             => [[ >digits ]]
pad       = pad-align pad-char pad-width => [[ <reversed> >quotation dup first 0 = [ drop [ ] ] when ]]

sign_     = [+ ]                 => [[ '[ dup CHAR: - swap index [ _ prefix ] unless ] ]]
sign      = (sign_)?             => [[ [ ] or ]]

width_    = "." ([0-9])*         => [[ second >digits '[ _ short head ] ]]
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
fmt-x     = "x"                  => [[ [ >hex ] ]]
fmt-X     = "X"                  => [[ [ >hex >upper ] ]]
unknown   = (.)*                 => [[ unknown-printf-directive ]]

strings_  = fmt-c|fmt-C|fmt-s|fmt-S|fmt-u
strings   = pad width strings_   => [[ <reversed> compose-all ]]

numbers_  = fmt-d|fmt-o|fmt-b|fmt-e|fmt-E|fmt-f|fmt-x|fmt-X
numbers   = sign pad numbers_    => [[ unclip-last prefix compose-all [ fix-sign ] append ]]

types     = strings|numbers

lists     = "[%" types ", %]"    => [[ second '[ _ map ", " join "{ " prepend " }" append ] ]]

assocs    = "[%" types ": %" types " %]" => [[ [ second ] [ fourth ] bi '[ unzip [ _ map ] dip _ map zip [ ":" join ] map ", " join "{ " prepend " }" append ] ]]

formats   = "%" (types|fmt-%|lists|assocs|unknown) => [[ second ]]

plain-text = (!("%").)+          => [[ >string ]]

text      = (formats|plain-text)* => [[ ]]

;EBNF

PRIVATE>

MACRO: printf ( format-string -- )
    parse-printf [ [ callable? ] count ] keep [
        dup string? [ 1quotation ] [ [ 1 - ] dip ] if
        over [ ndip ] 2curry
    ] map nip [ compose-all ] [ length ] bi '[
        @ output-stream get [ stream-write ] curry _ napply
    ] ;

: sprintf ( format-string -- result )
    [ printf ] with-string-writer ; inline

: vprintf ( seq format-string -- )
    parse-printf output-stream get '[
        dup string? [
            [ unclip-slice ] dip call( x -- y )
        ] unless _ stream-write
    ] each drop ;

: vsprintf ( seq format-string -- result )
    [ vprintf ] with-string-writer ; inline

<PRIVATE

: pad-00 ( n -- string ) number>string 2 CHAR: 0 pad-head ; inline

: pad-000 ( n -- string ) number>string 3 CHAR: 0 pad-head ; inline

: >time ( timestamp -- string )
    [ hour>> ] [ minute>> ] [ second>> floor ] tri 3array
    [ pad-00 ] map ":" join ; inline

: >date ( timestamp -- string )
    [ month>> ] [ day>> ] [ year>> ] tri 3array
    [ pad-00 ] map "/" join ; inline

: >datetime ( timestamp -- string )
    [
       {
          [ day-of-week day-abbreviation3 ]
          [ month>> month-abbreviation ]
          [ day>> pad-00 ]
          [ >time ]
          [ year>> number>string ]
       } cleave
    ] output>array " " join ; inline

: (week-of-year) ( timestamp day -- n )
    [ dup clone 1 >>month 1 >>day day-of-week dup ] dip > [ 7 swap - ] when
    [ day-of-year ] dip 2dup < [ 0 2nip ] [ - 7 / 1 + >fixnum ] if ;

: week-of-year-sunday ( timestamp -- n ) 0 (week-of-year) ; inline

: week-of-year-monday ( timestamp -- n ) 1 (week-of-year) ; inline

EBNF: parse-strftime

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
unknown   = (.)*                 => [[ "Unknown directive" throw ]]

formats_  = fmt-%|fmt-a|fmt-A|fmt-b|fmt-B|fmt-c|fmt-d|fmt-H|fmt-I|
            fmt-j|fmt-m|fmt-M|fmt-p|fmt-S|fmt-U|fmt-w|fmt-W|fmt-x|
            fmt-X|fmt-y|fmt-Y|fmt-Z|unknown

formats   = "%" (formats_)       => [[ second ]]

plain-text = (!("%").)+          => [[ >string ]]

text      = (formats|plain-text)* => [[ ]]

;EBNF

PRIVATE>

MACRO: strftime ( format-string -- )
    parse-strftime [
        dup string? [
            '[ _ swap push-all ]
        ] [
            '[ over @ swap push-all ]
        ] if
    ] map '[
        SBUF" " clone [ _ cleave drop ] keep "" like
    ] ;
