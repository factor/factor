! Copyright (C) 2007 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.

USING: arrays assocs kernel math math.vectors namespaces
quotations sequences sequences.private strings ;
IN: roman

<PRIVATE

: roman-digits ( -- seq )
    { "m" "cm" "d" "cd" "c" "xc" "l" "xl" "x" "ix" "v" "iv" "i" } ;

: roman-values ( -- seq )
    { 1000 900 500 400 100 90 50 40 10 9 5 4 1 } ;

TUPLE: roman-range-error n ;

: roman-range-check ( n -- )
    dup 1 3999 between? [
        drop
    ] [
        roman-range-error construct-boa throw
    ] if ;

: ,, building get peek push ;
: v, V{ } clone , ;
: ,v building get dup peek empty? [ dup pop* ] when drop ;

: monotonic-split ( seq quot -- newseq )
    [
        >r dup unclip add r>
        v, [ pick ,, call [ v, ] unless ] curry 2each ,v
    ] { } make ;

: roman<= ( ch1 ch2 -- ? )
    [ 1string roman-digits index ] 2apply >= ;

: roman>n ( ch -- n )
    1string roman-digits index roman-values nth ;

: (>roman) ( n -- )
    roman-values roman-digits [
        >r /mod swap r> <repetition> concat %
    ] 2each drop ;

: (roman>) ( seq -- n )
    dup [ roman>n ] map swap all-eq? [
        sum
    ] [
        first2 swap -
    ] if ;

PRIVATE>

: >roman ( n -- str )
    dup roman-range-check [
        (>roman)
    ] "" make ;

: >ROMAN ( n -- str ) >roman >upper ;

: roman> ( str -- n )
    >lower [ roman<= ] monotonic-split [
        (roman>)
    ] map sum ;

<PRIVATE

: 2roman> ( str1 str2 -- m n )
    [ roman> ] 2apply ;

: binary-roman-op ( str1 str2 quot -- str3 )
    >r 2roman> r> call >roman ; inline

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
    [ /mod ] binary-roman-op >r >roman r> ;
