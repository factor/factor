! Copyright (c) 2009 Samuel Tardieu.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays assocs combinators kernel math math.functions
math.parser math.text.utils sequences splitting ;
IN: math.text.french

<PRIVATE

DEFER: basic

CONSTANT: literals
    H{
        { 0 "zéro" } { 1 "un" } { 2 "deux" } { 3 "trois" } { 4 "quatre" }
        { 5 "cinq" } { 6 "six" } { 7 "sept" } { 8 "huit" } { 9 "neuf" }
        { 10 "dix" } { 11 "onze" } { 12 "douze" } { 13 "treize" }
        { 14 "quatorze" } { 15 "quinze" } { 16 "seize" } { 17 "dix-sept" }
        { 18 "dix-huit" } { 19 "dix-neuf" } { 20 "vingt" } { 30 "trente" }
        { 40 "quarante" } { 50 "cinquante" } { 60 "soixante" }
        { 71 "soixante et onze" } { 80 "quatre-vingts" }
        { 81 "quatre-vingt-un" }
        { 100 "cent" } { 1000 "mille" }
    }

MEMO: units ( -- seq ) ! up to 10^99
    { "m" "b" "tr" "quadr" "quint" "sext" "sept" "oct"
      "non" "déc" "unodéc" "duodéc" "trédéc" "quattuordéc"
      "quindéc" "sexdéc" }
      [ [ "illion" append ] [ "illiard" append ] bi 2array ] map concat
      "mille" prefix ;

! The only plurals we have to remove are "quatre-vingts" and "cents",
! which are also the only strings ending with "ts".
: unpluralize ( str -- newstr ) dup "ts" tail? [ but-last ] when ;
: pluralize ( str -- newstr ) dup "s" tail? [ CHAR: s suffix ] unless ;

: space-append ( str1 str2 -- str ) " " glue ;

: dash-append ( str1 str2 -- str ) "-" glue ;

! Numbers below 1000000 use dashes between them. Pluralized prefixes
! must be unpluralized.
: complete ( str n -- str )
    { { 0 [ ] }
      { 1 [ "-et-un" append ] }
      [ [ unpluralize ] dip basic "-" glue ] } case ;

: smaller-than-60 ( n -- str )
    dup 10 mod [ - ] keep [ basic ] dip complete ;

: base-onto ( n b -- str ) [ nip literals at ] [ - ] 2bi complete ;

: smaller-than-80 ( n -- str ) 60 base-onto ;

: smaller-than-100 ( n -- str ) 80 base-onto ;

: smaller-than-1000 ( n -- str )
    100 /mod
    [ "cent" swap dup 1 = [ drop ] [ basic swap dash-append ] if ]
    [ [ pluralize ] [ basic dash-append ] if-zero ] bi* ;

: smaller-than-2000 ( n -- str ) "mille" swap 1000 - complete ;

: smaller-than-1000000 ( n -- str )
    1000 /mod [ basic unpluralize "-mille" append ] dip complete ;

: n-units ( n unit -- str/f )
    {
        { [ over zero? ] [ 2drop f ] }
        { [ over 1 = ] [ [ basic ] dip space-append ] }
        [ [ basic ] dip space-append pluralize ]
    } cond ;

: over-1000000 ( n -- str )
    3 digit-groups [ 1 + units nth n-units ] map-index sift
    reverse join-words ;

: decompose ( n -- str ) 1000000 /mod [ over-1000000 ] dip
    dup 0 > [ basic space-append ] [ drop ] if ;

: basic ( n -- str )
    {
        { [ dup literals key? ] [ literals at ] }
        { [ dup 0 < ] [ abs basic "moins " swap append ] }
        { [ dup 60 < ] [ smaller-than-60 ] }
        { [ dup 80 < ] [ smaller-than-80 ] }
        { [ dup 100 < ] [ smaller-than-100 ] }
        { [ dup 1000 < ] [ smaller-than-1000 ] }
        { [ dup 2000 < ] [ smaller-than-2000 ] }
        { [ dup 1000000 < ] [ smaller-than-1000000 ] }
        [ decompose ]
    } cond ;

: ieme ( str -- str )
    dup "ts" tail? [ but-last ] when
    dup "e" tail? [ but-last ] when
    dup "q" tail? [ CHAR: u suffix ] when
    "ième" append ;

: divisor ( n -- str )
    {
        { 2 [ "demi" ] }
        { 3 [ "tiers" ] }
        { 4 [ "quart" ] }
        [ basic ieme ]
    } case ;

PRIVATE>

GENERIC: number>text ( n -- str )

M: integer number>text
    dup abs 102 10^ >= [ number>string ] [ basic ] if ;

M: ratio number>text
    >fraction [ [ number>text ] keep ] [ divisor ] bi*
    swap abs 1 > [ pluralize ] when
    space-append ;
