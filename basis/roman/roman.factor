! Copyright (C) 2007 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs kernel math math.order math.vectors
namespaces make quotations sequences splitting.monotonic
sequences.private strings unicode.case lexer parser
grouping ;
IN: roman

<PRIVATE

: roman-digits ( -- seq )
    { "m" "cm" "d" "cd" "c" "xc" "l" "xl" "x" "ix" "v" "iv" "i" } ;

: roman-values ( -- seq )
    { 1000 900 500 400 100 90 50 40 10 9 5 4 1 } ;

ERROR: roman-range-error n ;

: roman-range-check ( n -- )
    dup 1 3999 between? [ drop ] [ roman-range-error ] if ;

: roman<= ( ch1 ch2 -- ? )
    [ 1string roman-digits index ] bi@ >= ;

: roman>n ( ch -- n )
    1string roman-digits index roman-values nth ;

: (>roman) ( n -- )
    roman-values roman-digits [
        [ /mod swap ] dip <repetition> concat %
    ] 2each drop ;

: (roman>) ( seq -- n )
    [ [ roman>n ] map ] [ all-eq? ] bi [
        sum
    ] [
        first2 swap -
    ] if ;

PRIVATE>

: >roman ( n -- str )
    dup roman-range-check
    [ (>roman) ] "" make ;

: >ROMAN ( n -- str ) >roman >upper ;

: roman> ( str -- n )
    >lower [ roman<= ] monotonic-split
    [ (roman>) ] sigma ;

<PRIVATE

: 2roman> ( str1 str2 -- m n )
    [ roman> ] bi@ ;

: binary-roman-op ( str1 str2 quot -- str3 )
    [ 2roman> ] dip call >roman ; inline

PRIVATE>

: roman+ ( str1 str2 -- str3 )
    [ + ] binary-roman-op ;

: roman- ( str1 str2 -- str3 )
    [ - ] binary-roman-op ;

: roman* ( str1 str2 -- str3 )
    [ * ] binary-roman-op ;

: roman/i ( str1 str2 -- str3 )
    [ /i ] binary-roman-op ;

: roman/mod ( str1 str2 -- str3 str4 )
    [ /mod ] binary-roman-op [ >roman ] dip ;

SYNTAX: ROMAN: scan roman> parsed ;
