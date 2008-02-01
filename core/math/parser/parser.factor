! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math.private namespaces sequences strings arrays
combinators splitting math assocs ;
IN: math.parser

DEFER: base>

: string>ratio ( str radix -- a/b )
    >r "/" split1 r> tuck base> >r base> r>
    2dup and [ / ] [ 2drop f ] if ;

: digit> ( ch -- n )
    H{
        { CHAR: 0 0 }
        { CHAR: 1 1 }
        { CHAR: 2 2 }
        { CHAR: 3 3 }
        { CHAR: 4 4 }
        { CHAR: 5 5 }
        { CHAR: 6 6 }
        { CHAR: 7 7 }
        { CHAR: 8 8 }
        { CHAR: 9 9 }
        { CHAR: A 10 }
        { CHAR: B 11 }
        { CHAR: C 12 }
        { CHAR: D 13 }
        { CHAR: E 14 }
        { CHAR: F 15 }
        { CHAR: a 10 }
        { CHAR: b 11 }
        { CHAR: c 12 }
        { CHAR: d 13 }
        { CHAR: e 14 }
        { CHAR: f 15 }
    } at ;

: digits>integer ( radix seq -- n )
    0 rot [ swapd * + ] curry reduce ;

: valid-digits? ( radix seq -- ? )
    {
        { [ dup empty? ] [ 2drop f ] }
        { [ f over memq? ] [ 2drop f ] }
        { [ t ] [ swap [ < ] curry all? ] }
    } cond ;

: string>digits ( str -- digits )
    [ digit> ] { } map-as ;

: string>integer ( str radix -- n/f )
    swap "-" ?head >r
    string>digits 2dup valid-digits?
    [ digits>integer r> [ neg ] when ] [ r> 3drop f ] if ;

: base> ( str radix -- n/f )
    {
        { [ CHAR: / pick member? ] [ string>ratio ] }
        { [ CHAR: . pick member? ] [ drop string>float ] }
        { [ t ] [ string>integer ] }
    } cond ;

: string>number ( str -- n/f ) 10 base> ;
: bin> ( str -- n/f ) 2 base> ;
: oct> ( str -- n/f ) 8 base> ;
: hex> ( str -- n/f ) 16 base> ;

: >digit ( n -- ch )
    dup 10 < [ CHAR: 0 + ] [ 10 - CHAR: a + ] if ;

: integer, ( num radix -- )
    dup 1 <= [ "Invalid radix" throw ] when
    dup >r /mod >digit , dup 0 >
    [ r> integer, ] [ r> 2drop ] if ;

GENERIC# >base 1 ( n radix -- str )

M: integer >base
    [
        over 0 < [
            swap neg swap integer, CHAR: - ,
        ] [
            integer,
        ] if
    ] "" make reverse ;

M: ratio >base
    [
        over numerator over >base %
        CHAR: / ,
        swap denominator swap >base %
    ] "" make ;

: fix-float ( str -- newstr )
    {
        {
            [ CHAR: e over member? ]
            [ "e" split1 >r fix-float "e" r> 3append ]
        } {
            [ CHAR: . over member? ]
            [ ]
        } {
            [ t ]
            [ ".0" append ]
        }
    } cond ;

M: float >base
    drop {
        { [ dup 1.0/0.0 = ] [ drop "1.0/0.0" ] }
        { [ dup -1.0/0.0 = ] [ drop "-1.0/0.0" ] }
        { [ dup fp-nan? ] [ drop "0.0/0.0" ] }
        { [ t ] [ float>string fix-float ] }
    } cond ;

: number>string ( n -- str ) 10 >base ;
: >bin ( n -- str ) 2 >base ;
: >oct ( n -- str ) 8 >base ;
: >hex ( n -- str ) 16 >base ;

: # ( n -- ) number>string % ;
