! Copyright (C) 2008 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors arrays calendar combinators io kernel fry 
macros math math.functions math.parser peg.ebnf sequences 
strings vectors ;

IN: time

: zero-pad 2 CHAR: 0 pad-left ; inline

: >timestring ( timestamp -- string ) 
    [ hour>> ] [ minute>> ] [ second>> floor ] tri 3array
    [ number>string zero-pad ] map ":" join ; inline

: >datestring ( timestamp -- string )
    [ month>> ] [ day>> ] [ year>> ] tri 3array
    [ number>string zero-pad ] map "/" join ; inline

: >datetimestring ( timestamp -- string ) 
    { [ day-of-week day-abbreviation3 ]
      [ month>> month-abbreviation ]
      [ day>> number>string zero-pad ]
      [ >timestring ]
      [ year>> number>string ]
    } cleave 3array [ 2array ] dip append " " join ; inline

: (week-of-year) ( timestamp day -- n )
    [ dup clone 1 >>month 1 >>day day-of-week dup ] dip > [ 7 swap - ] when
    [ day-of-year ] dip 2dup < [ 0 2nip ] [ - 7 / 1+ >fixnum ] if ;

: week-of-year-sunday ( timestamp -- n ) 0 (week-of-year) ; inline

: week-of-year-monday ( timestamp -- n ) 1 (week-of-year) ; inline


<PRIVATE

EBNF: parse-format-string

fmt-%     = "%"                  => [[ [ "%" ] ]]
fmt-a     = "a"                  => [[ [ dup day-of-week day-abbreviation3 ] ]]
fmt-A     = "A"                  => [[ [ dup day-of-week day-name ] ]] 
fmt-b     = "b"                  => [[ [ dup month>> month-abbreviation ] ]]
fmt-B     = "B"                  => [[ [ dup month>> month-name ] ]] 
fmt-c     = "c"                  => [[ [ dup >datetimestring ] ]] 
fmt-d     = "d"                  => [[ [ dup day>> number>string zero-pad ] ]] 
fmt-H     = "H"                  => [[ [ dup hour>> number>string zero-pad ] ]]
fmt-I     = "I"                  => [[ [ dup hour>> dup 12 > [ 12 - ] when number>string zero-pad ] ]] 
fmt-j     = "j"                  => [[ [ dup day-of-year number>string ] ]] 
fmt-m     = "m"                  => [[ [ dup month>> number>string zero-pad ] ]] 
fmt-M     = "M"                  => [[ [ dup minute>> number>string zero-pad ] ]] 
fmt-p     = "p"                  => [[ [ dup hour>> 12 < "AM" "PM" ? ] ]] 
fmt-S     = "S"                  => [[ [ dup second>> round number>string zero-pad ] ]] 
fmt-U     = "U"                  => [[ [ dup week-of-year-sunday ] ]] 
fmt-w     = "w"                  => [[ [ dup day-of-week number>string ] ]] 
fmt-W     = "W"                  => [[ [ dup week-of-year-monday ] ]] 
fmt-x     = "x"                  => [[ [ dup >datestring ] ]] 
fmt-X     = "X"                  => [[ [ dup >timestring ] ]] 
fmt-y     = "y"                  => [[ [ dup year>> 100 mod number>string ] ]] 
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
    parse-format-string [ length ] keep [ ] join 
    '[ _ <vector> @ reverse concat nip ] ;


