! Copyright (C) 2008 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: io io.encodings.ascii io.files io.streams.string combinators
kernel sequences splitting strings math math.parser macros
fry peg.ebnf ascii unicode.case arrays quotations vectors ;

IN: printf

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

: max-digits ( string digits -- string ) 
    [ "." split1 ] dip [ CHAR: 0 pad-right ] [ head-slice ] bi "." swap 3append ;

: max-width ( string length -- string ) 
    short head ;

: >exponential ( n -- base exp ) 
    [ 0 < ] keep abs 0 
    [ swap dup [ 10.0 >= ] keep 1.0 < or ] 
    [ dup 10.0 >= 
      [ 10.0 / [ 1+ ] dip swap ] 
      [ 10.0 * [ 1- ] dip swap ] if
    ] [ swap ] while 
    [ number>string ] dip 
    dup abs number>string 2 CHAR: 0 pad-left
    [ 0 < "-" "+" ? ] dip append
    "e" prepend 
    rot [ [ "-" prepend ] dip ] when ; 

EBNF: parse-format-string

zero      = "0"                  => [[ CHAR: 0 ]]
char      = "'" (.)              => [[ second ]]

pad-char  = (zero|char)?         => [[ CHAR: \s or 1quotation ]]
pad-align = ("-")?               => [[ [ pad-right ] [ pad-left ] ? ]] 
pad-width = ([0-9])*             => [[ >digits 1quotation ]]
pad       = pad-align pad-char pad-width => [[ reverse compose-all [ first ] keep swap 0 = [ drop [ ] ] when ]]

sign      = ("+")?               => [[ [ dup CHAR: - swap index not [ "+" prepend ] when ] [ ] ? ]]

width_    = "." ([0-9])*         => [[ second >digits '[ _ max-width ] ]]
width     = (width_)?            => [[ [ ] or ]] 

digits_   = "." ([0-9])*         => [[ second >digits '[ _ max-digits ] ]]
digits    = (digits_)?           => [[ [ ] or ]]

fmt-%     = "%"                  => [[ [ "%" ] ]] 
fmt-c     = "c"                  => [[ [ 1string ] ]]
fmt-C     = "C"                  => [[ [ 1string >upper ] ]]
fmt-s     = "s"                  => [[ [ ] ]]
fmt-S     = "S"                  => [[ [ >upper ] ]]
fmt-d     = "d"                  => [[ [ >fixnum number>string ] ]]
fmt-e     = "e"                  => [[ [ >exponential ] ]]
fmt-E     = "E"                  => [[ [ >exponential >upper ] ]]
fmt-f     = "f"                  => [[ [ >float number>string ] ]] 
fmt-x     = "x"                  => [[ [ >hex ] ]]
fmt-X     = "X"                  => [[ [ >hex >upper ] ]]
unknown   = (.)*                 => [[ "Unknown directive" throw ]]

chars     = fmt-c | fmt-C
strings   = pad width (fmt-s|fmt-S) => [[ reverse compose-all ]]
decimals  = fmt-d
exps      = digits (fmt-e|fmt-E) => [[ reverse [ swap ] join [ swap append ] append ]] 
floats    = digits fmt-f         => [[ reverse compose-all ]]
hex       = fmt-x | fmt-X
numbers   = sign pad (decimals|floats|hex|exps) => [[ reverse first3 swap 3append [ fix-sign ] append ]]

formats   = "%" (chars|strings|numbers|fmt-%|unknown) => [[ second '[ _ dip ] ]]

plain-text = (!("%").)+           => [[ >string '[ _ swap ] ]]

text      = (formats|plain-text)* => [[ reverse [ [ dup [ push ] dip ] append ] map ]]

;EBNF

PRIVATE>

MACRO: printf ( format-string -- )
    parse-format-string [ length ] keep compose-all '[ _ <vector> @ reverse [ write ] each ] ;

: sprintf ( format-string -- )
    [ printf ] with-string-writer ;


