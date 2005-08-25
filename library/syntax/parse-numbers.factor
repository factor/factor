! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: parser
USING: errors generic kernel math namespaces sequences strings ;

! Number parsing

: not-a-number "Not a number" throw ;

GENERIC: digit> ( ch -- n )
M: digit  digit> CHAR: 0 - ;
M: letter digit> CHAR: a - 10 + ;
M: LETTER digit> CHAR: A - 10 + ;
M: object digit> not-a-number ;

: digit+ ( num digit base -- num )
    2dup < [ rot * + ] [ not-a-number ] ifte ;

: (base>) ( base str -- num )
    dup empty? [
        not-a-number
    ] [
        0 [ digit> pick digit+ ] reduce nip
    ] ifte ;

: base> ( str base -- num )
    #! Convert a string to an integer. Throw an error if
    #! conversion fails.
    swap "-" ?head [ (base>) neg ] [ (base>) ] ifte ;

GENERIC: string>number ( str -- num )

M: string string>number 10 base> ;

PREDICATE: string potential-ratio CHAR: / swap member? ;
M: potential-ratio string>number ( str -- num )
    "/" split1 >r 10 base> r> 10 base> / ;

PREDICATE: string potential-float CHAR: . swap member? ;
M: potential-float string>number ( str -- num )
    str>float ;

: bin> 2 base> ;
: oct> 8 base> ;
: hex> 16 base> ;

GENERIC: number>string ( str -- num )

: >digit ( n -- ch )
    dup 10 < [ CHAR: 0 + ] [ 10 - CHAR: a + ] ifte ;

: integer, ( num radix -- )
    dup >r /mod >digit , dup 0 > [
        r> integer,
    ] [
        r> 2drop
    ] ifte ;

: >base ( num radix -- string )
    #! Convert a number to a string in a certain base.
    [
        over 0 < [
            swap neg swap integer, CHAR: - ,
        ] [
            integer,
        ] ifte
    ] "" make reverse ;

: >bin ( num -- string ) 2 >base ;
: >oct ( num -- string ) 8 >base ;
: >hex ( num -- string ) 16 >base ;

M: integer number>string ( obj -- str ) 10 >base ;

M: ratio number>string ( num -- str )
    [
        dup
        numerator number>string %
        CHAR: / ,
        denominator number>string %
    ] "" make ;

: fix-float ( str -- str )
    #! This is terrible. Will go away when we do our own float
    #! output.
    CHAR: . over member? [ ".0" append ] unless ;

M: float number>string ( float -- str )
    (unparse-float) fix-float ;
