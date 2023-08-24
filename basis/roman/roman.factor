! Copyright (C) 2007 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors combinators.smart effects.parser
generalizations grouping kernel lexer math math.order
parser quotations sequences splitting.monotonic strings unicode
words ;
IN: roman

<PRIVATE

CONSTANT: roman-digits
    { "m" "cm" "d" "cd" "c" "xc" "l" "xl" "x" "ix" "v" "iv" "i" }

CONSTANT: roman-values
    { 1000 900 500 400 100 90 50 40 10 9 5 4 1 }

ERROR: roman-range-error n ;

: roman-range-check ( n -- n )
    dup 1 10000 between? [ roman-range-error ] unless ;

: roman-digit-index ( ch -- n )
    1string roman-digits index ; inline

: roman-digit>= ( ch1 ch2 -- ? )
    [ roman-digit-index ] bi@ >= ;

: roman-digit-value ( ch -- n )
    roman-digit-index roman-values nth ;

: roman-value ( seq -- n )
    [ [ roman-digit-value ] map ] [ all-eq? ] bi
    [ sum ] [ first2 swap - ] if ;

PRIVATE>

: >roman ( n -- str )
    roman-range-check
    roman-values roman-digits [
        [ /mod swap ] dip <repetition> concat
    ] 2map "" concat-as nip ;

: >ROMAN ( n -- str ) >roman >upper ;

: roman> ( str -- n )
    >lower [ roman-digit>= ] monotonic-split
    [ roman-value ] map-sum ;

<PRIVATE

MACRO: binary-roman-op ( quot -- quot' )
    [ inputs ] [ ] [ outputs ] tri
    '[ [ roman> ] _ napply @ [ >roman ] _ napply ] ;

PRIVATE>

<<

SYNTAX: ROMAN-OP:
    scan-word [ name>> "roman" prepend create-word-in ] keep
    1quotation '[ _ binary-roman-op ]
    scan-effect define-declared ;

>>

ROMAN-OP: + ( x y -- z )
ROMAN-OP: - ( x y -- z )
ROMAN-OP: * ( x y -- z )
ROMAN-OP: /i ( x y -- z )
ROMAN-OP: /mod ( x y -- z w )

SYNTAX: ROMAN: scan-token roman> suffix! ;
