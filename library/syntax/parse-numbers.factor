! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: parser
USING: errors generic kernel math sequences strings ;

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

GENERIC: str>number ( str -- num )

M: string str>number 10 base> ;

PREDICATE: string potential-ratio CHAR: / swap member? ;
M: potential-ratio str>number ( str -- num )
    "/" split1 >r 10 base> r> 10 base> / ;

PREDICATE: string potential-float CHAR: . swap member? ;
M: potential-float str>number ( str -- num )
    str>float ;

: bin> 2 base> ;
: oct> 8 base> ;
: dec> 10 base> ;
: hex> 16 base> ;
