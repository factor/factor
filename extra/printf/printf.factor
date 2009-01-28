! Copyright (C) 2008 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: io io.encodings.ascii io.files io.streams.string combinators
kernel sequences splitting strings math math.functions math.parser 
macros fry peg.ebnf ascii unicode.case arrays quotations vectors ;

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

: pad-digits ( string digits -- string' )
    [ "." split1 ] dip [ CHAR: 0 pad-right ] [ head-slice ] bi "." glue ;

: max-digits ( n digits -- n' )
    10 swap ^ [ * round ] keep / ;

: max-width ( string length -- string' ) 
    short head ;

: >exp ( x -- exp base )
    [ 
        abs 0 swap
        [ dup [ 10.0 >= ] [ 1.0 < ] bi or ]
        [ dup 10.0 >=
          [ 10.0 / [ 1+ ] dip ]
          [ 10.0 * [ 1- ] dip ] if
        ] [ ] while 
     ] keep 0 < [ neg ] when ;

: exp>string ( exp base digits -- string )
    [ max-digits ] keep -rot
    [
        [ 0 < "-" "+" ? ]
        [ abs number>string 2 CHAR: 0 pad-left ] bi 
        "e" -rot 3append
    ]
    [ number>string ] bi*
    rot pad-digits prepend ;

EBNF: parse-format-string

zero      = "0"                  => [[ CHAR: 0 ]]
char      = "'" (.)              => [[ second ]]

pad-char  = (zero|char)?         => [[ CHAR: \s or ]]
pad-align = ("-")?               => [[ \ pad-right \ pad-left ? ]] 
pad-width = ([0-9])*             => [[ >digits ]]
pad       = pad-align pad-char pad-width => [[ reverse >quotation dup first 0 = [ drop [ ] ] when ]]

sign      = ("+")?               => [[ [ dup CHAR: - swap index [ "+" prepend ] unless ] [ ] ? ]]

width_    = "." ([0-9])*         => [[ second >digits '[ _ max-width ] ]]
width     = (width_)?            => [[ [ ] or ]] 

digits_   = "." ([0-9])*         => [[ second >digits ]]
digits    = (digits_)?           => [[ 6 or ]]

fmt-%     = "%"                  => [[ [ "%" ] ]] 
fmt-c     = "c"                  => [[ [ 1string ] ]]
fmt-C     = "C"                  => [[ [ 1string >upper ] ]]
fmt-s     = "s"                  => [[ [ ] ]]
fmt-S     = "S"                  => [[ [ >upper ] ]]
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

formats   = "%" (strings|numbers|fmt-%|unknown) => [[ second '[ _ dip ] ]]

plain-text = (!("%").)+          => [[ >string '[ _ swap ] ]]

text      = (formats|plain-text)* => [[ reverse [ [ [ push ] keep ] append ] map ]]

;EBNF

PRIVATE>

MACRO: printf ( format-string -- )
    parse-format-string [ length ] keep compose-all '[ _ <vector> @ reverse [ write ] each ] ;

: sprintf ( format-string -- result )
    [ printf ] with-string-writer ; inline


