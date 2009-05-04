! Copyright (C) 2008 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors arrays ascii assocs calendar combinators fry kernel 
generalizations io io.encodings.ascii io.files io.streams.string
macros math math.functions math.parser peg.ebnf quotations
sequences splitting strings unicode.case vectors combinators.smart ;

IN: formatting

<PRIVATE

: compose-all ( seq -- quot )
    [ ] [ compose ] reduce ;

: fix-sign ( string -- string )
    dup CHAR: 0 swap index 0 = 
      [ dup 0 swap [ [ CHAR: 0 = not ] keep digit? and ] find-from
         [ dup 1- rot dup [ nth ] dip swap
            {
               { CHAR: - [ [ 1- ] dip remove-nth "-" prepend ] }
               { CHAR: + [ [ 1- ] dip remove-nth "+" prepend ] }
               [ drop swap drop ] 
            } case 
         ] [ drop ] if
      ] when ;

: >digits ( string -- digits ) 
    [ 0 ] [ string>number ] if-empty ;

: pad-digits ( string digits -- string' )
    [ "." split1 ] dip [ CHAR: 0 pad-tail ] [ head-slice ] bi "." glue ;

: max-digits ( n digits -- n' )
    10 swap ^ [ * round ] keep / ; inline

: >exp ( x -- exp base )
    [ 
        abs 0 swap
        [ dup [ 10.0 >= ] [ 1.0 < ] bi or ]
        [ dup 10.0 >=
          [ 10.0 / [ 1+ ] dip ]
          [ 10.0 * [ 1- ] dip ] if
        ] while 
     ] keep 0 < [ neg ] when ;

: exp>string ( exp base digits -- string )
    [ max-digits ] keep -rot
    [
        [ 0 < "-" "+" ? ]
        [ abs number>string 2 CHAR: 0 pad-head ] bi 
        "e" -rot 3append
    ]
    [ number>string ] bi*
    rot pad-digits prepend ;

EBNF: parse-printf

zero      = "0"                  => [[ CHAR: 0 ]]
char      = "'" (.)              => [[ second ]]

pad-char  = (zero|char)?         => [[ CHAR: \s or ]]
pad-align = ("-")?               => [[ \ pad-tail \ pad-head ? ]] 
pad-width = ([0-9])*             => [[ >digits ]]
pad       = pad-align pad-char pad-width => [[ reverse >quotation dup first 0 = [ drop [ ] ] when ]]

sign      = ("+")?               => [[ [ dup CHAR: - swap index [ "+" prepend ] unless ] [ ] ? ]]

width_    = "." ([0-9])*         => [[ second >digits '[ _ short head ] ]]
width     = (width_)?            => [[ [ ] or ]] 

digits_   = "." ([0-9])*         => [[ second >digits ]]
digits    = (digits_)?           => [[ 6 or ]]

fmt-%     = "%"                  => [[ [ "%" ] ]] 
fmt-c     = "c"                  => [[ [ 1string ] ]]
fmt-C     = "C"                  => [[ [ 1string >upper ] ]]
fmt-s     = "s"                  => [[ [ dup number? [ number>string ] when ] ]]
fmt-S     = "S"                  => [[ [ dup number? [ number>string ] when >upper ] ]]
fmt-d     = "d"                  => [[ [ >fixnum number>string ] ]]
fmt-e     = digits "e"           => [[ first '[ >exp _ exp>string ] ]]
fmt-E     = digits "E"           => [[ first '[ >exp _ exp>string >upper ] ]]
fmt-f     = digits "f"           => [[ first dup '[ >float _ max-digits number>string _ pad-digits ] ]] 
fmt-x     = "x"                  => [[ [ >hex ] ]]
fmt-X     = "X"                  => [[ [ >hex >upper ] ]]
unknown   = (.)*                 => [[ "Unknown directive" throw ]]

strings_  = fmt-c|fmt-C|fmt-s|fmt-S
strings   = pad width strings_   => [[ reverse compose-all ]]

numbers_  = fmt-d|fmt-e|fmt-E|fmt-f|fmt-x|fmt-X
numbers   = sign pad numbers_    => [[ unclip-last prefix compose-all [ fix-sign ] append ]]

types     = strings|numbers 

lists     = "[%" types ", %]"    => [[ second '[ _ map ", " join "{ " prepend " }" append ] ]] 

assocs    = "[%" types ": %" types " %]" => [[ [ second ] [ fourth ] bi '[ unzip [ _ map ] dip _ map zip [ ":" join ] map ", " join "{ " prepend " }" append ] ]]

formats   = "%" (types|fmt-%|lists|assocs|unknown) => [[ second '[ _ dip ] ]]

plain-text = (!("%").)+          => [[ >string '[ _ swap ] ]]

text      = (formats|plain-text)* => [[ reverse [ [ [ push ] keep ] append ] map ]]

;EBNF

PRIVATE>

MACRO: printf ( format-string -- )
    parse-printf [ length ] keep compose-all '[ _ <vector> @ reverse [ write ] each ] ;

: sprintf ( format-string -- result )
    [ printf ] with-string-writer ; inline

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
    [ day-of-year ] dip 2dup < [ 0 2nip ] [ - 7 / 1+ >fixnum ] if ;

: week-of-year-sunday ( timestamp -- n ) 0 (week-of-year) ; inline

: week-of-year-monday ( timestamp -- n ) 1 (week-of-year) ; inline

EBNF: parse-strftime

fmt-%     = "%"                  => [[ [ "%" ] ]]
fmt-a     = "a"                  => [[ [ dup day-of-week day-abbreviation3 ] ]]
fmt-A     = "A"                  => [[ [ dup day-of-week day-name ] ]]
fmt-b     = "b"                  => [[ [ dup month>> month-abbreviation ] ]]
fmt-B     = "B"                  => [[ [ dup month>> month-name ] ]]
fmt-c     = "c"                  => [[ [ dup >datetime ] ]]
fmt-d     = "d"                  => [[ [ dup day>> pad-00 ] ]]
fmt-H     = "H"                  => [[ [ dup hour>> pad-00 ] ]]
fmt-I     = "I"                  => [[ [ dup hour>> dup 12 > [ 12 - ] when pad-00 ] ]]
fmt-j     = "j"                  => [[ [ dup day-of-year pad-000 ] ]]
fmt-m     = "m"                  => [[ [ dup month>> pad-00 ] ]]
fmt-M     = "M"                  => [[ [ dup minute>> pad-00 ] ]]
fmt-p     = "p"                  => [[ [ dup hour>> 12 < "AM" "PM" ? ] ]]
fmt-S     = "S"                  => [[ [ dup second>> floor pad-00 ] ]]
fmt-U     = "U"                  => [[ [ dup week-of-year-sunday pad-00 ] ]]
fmt-w     = "w"                  => [[ [ dup day-of-week number>string ] ]]
fmt-W     = "W"                  => [[ [ dup week-of-year-monday pad-00 ] ]]
fmt-x     = "x"                  => [[ [ dup >date ] ]]
fmt-X     = "X"                  => [[ [ dup >time ] ]]
fmt-y     = "y"                  => [[ [ dup year>> 100 mod pad-00 ] ]]
fmt-Y     = "Y"                  => [[ [ dup year>> number>string ] ]]
fmt-Z     = "Z"                  => [[ [ "Not yet implemented" throw ] ]]
unknown   = (.)*                 => [[ "Unknown directive" throw ]]

formats_  = fmt-%|fmt-a|fmt-A|fmt-b|fmt-B|fmt-c|fmt-d|fmt-H|fmt-I|
            fmt-j|fmt-m|fmt-M|fmt-p|fmt-S|fmt-U|fmt-w|fmt-W|fmt-x|
            fmt-X|fmt-y|fmt-Y|fmt-Z|unknown

formats   = "%" (formats_)       => [[ second '[ _ dip ] ]]

plain-text = (!("%").)+          => [[ >string '[ _ swap ] ]]

text      = (formats|plain-text)* => [[ reverse [ [ [ push ] keep ] append ] map ]]

;EBNF

PRIVATE>

MACRO: strftime ( format-string -- )
    parse-strftime [ length ] keep [ ] join
    '[ _ <vector> @ reverse concat nip ] ;
