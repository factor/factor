! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: math
USING: errors generic kernel math-internals namespaces sequences
strings ;

: not-a-number "Not a number" throw ;

DEFER: base>

: string>ratio ( "a/b" radix -- a/b )
    >r "/" split1 r> tuck base> >r base> r> / ;

GENERIC: digit> ( ch -- n )
M: digit  digit> CHAR: 0 - ;
M: letter digit> CHAR: a - 10 + ;
M: LETTER digit> CHAR: A - 10 + ;
M: object digit> not-a-number ;

: digit+ ( num digit base -- num )
    2dup < [ rot * + ] [ not-a-number ] if ;

: (string>integer) ( base str -- num )
    dup empty? [
        not-a-number
    ] [
        0 [ digit> pick digit+ ] reduce nip
    ] if ;

: string>integer ( string -- n )
    swap "-" ?head >r (string>integer) r> [ neg ] when ;

: base> ( string radix -- n )
    {
        { [ CHAR: / pick member? ] [ string>ratio ] }
        { [ CHAR: . pick member? ] [ drop string>float ] }
        { [ t ] [ string>integer ] }
    } cond ;

: string>number ( string -- num ) 10 base> ;
: bin> ( string -- num ) 2 base> ;
: oct> ( string -- num ) 8 base> ;
: hex> ( string -- num ) 16 base> ;

: >digit ( n -- ch )
    dup 10 < [ CHAR: 0 + ] [ 10 - CHAR: a + ] if ;

: integer, ( num radix -- )
    dup >r /mod >digit , dup 0 >
    [ r> integer, ] [ r> 2drop ] if ;

G: >base ( num radix -- string ) 1 standard-combination ;

M: integer >base ( num radix -- string )
    [
        over 0 < [
            swap neg swap integer, CHAR: - ,
        ] [
            integer,
        ] if
    ] "" make reverse ;

M: ratio >base ( num radix -- string )
    [
        over numerator over >base %
        CHAR: / ,
        swap denominator swap >base %
    ] "" make ;

: fix-float
    CHAR: . over member? [ ".0" append ] unless ;

M: float >base ( num radix -- string )
    drop {
        { [ dup 1.0/0.0 = ] [ drop "1.0/0.0" ] }
        { [ dup -1.0/0.0 = ] [ drop "-1.0/0.0" ] }
        { [ dup fp-nan? ] [ drop "0.0/0.0" ] }
        { [ t ] [ float>string fix-float ] }
    } cond ;

: number>string ( num -- string ) 10 >base ;
: >bin ( num -- string ) 2 >base ;
: >oct ( num -- string ) 8 >base ;
: >hex ( num -- string ) 16 >base ;
