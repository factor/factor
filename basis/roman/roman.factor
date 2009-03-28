! Copyright (C) 2007 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs fry generalizations grouping
kernel lexer macros make math math.order math.vectors
namespaces parser quotations sequences sequences.private
splitting.monotonic stack-checker strings unicode.case
words effects ;
IN: roman

<PRIVATE

CONSTANT: roman-digits
    { "m" "cm" "d" "cd" "c" "xc" "l" "xl" "x" "ix" "v" "iv" "i" }

CONSTANT: roman-values
    { 1000 900 500 400 100 90 50 40 10 9 5 4 1 }

ERROR: roman-range-error n ;

: roman-range-check ( n -- )
    dup 1 3999 between? [ drop ] [ roman-range-error ] if ;

: roman-digit-index ( ch -- n )
    1string roman-digits index ; inline

: roman<= ( ch1 ch2 -- ? )
    [ roman-digit-index ] bi@ >= ;

: roman>n ( ch -- n )
    roman-digit-index roman-values nth ;

: (>roman) ( n -- )
    roman-values roman-digits [
        [ /mod swap ] dip <repetition> concat %
    ] 2each drop ;

: (roman>) ( seq -- n )
    [ [ roman>n ] map ] [ all-eq? ] bi
    [ sum ] [ first2 swap - ] if ;

PRIVATE>

: >roman ( n -- str )
    dup roman-range-check [ (>roman) ] "" make ;

: >ROMAN ( n -- str ) >roman >upper ;

: roman> ( str -- n )
    >lower [ roman<= ] monotonic-split [ (roman>) ] sigma ;

<PRIVATE

MACRO: binary-roman-op ( quot -- quot' )
    [ infer in>> ] [ ] [ infer out>> ] tri
    '[ [ roman> ] _ napply @ [ >roman ] _ napply ] ;

PRIVATE>

<<
SYNTAX: ROMAN-OP:
    scan-word [ name>> "roman" prepend create-in ] keep
    1quotation '[ _ binary-roman-op ]
    dup infer [ in>> ] [ out>> ] bi
    [ "string" <repetition> ] bi@ <effect> define-declared ;
>>

ROMAN-OP: +
ROMAN-OP: -
ROMAN-OP: *
ROMAN-OP: /i
ROMAN-OP: /mod

SYNTAX: ROMAN: scan roman> parsed ;
