! Copyright (C) 2004, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math.private namespaces sequences sequences.private
strings arrays combinators splitting math assocs byte-arrays make ;
IN: math.parser

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
        { CHAR: , f }
    } at* [ drop 255 ] unless ; inline

: string>digits ( str -- digits )
    [ digit> ] B{ } map-as ; inline

: (digits>integer) ( valid? accum digit radix -- valid? accum )
    over [
        2dup < [ swapd * + ] [ 2drop 2drop f 0 ] if
    ] [ 2drop ] if ; inline

: each-digit ( seq radix quot -- n/f )
    [ t 0 ] 3dip curry each swap [ drop f ] unless ; inline

: digits>integer ( seq radix -- n/f )
    [ (digits>integer) ] each-digit ; inline

DEFER: base>

<PRIVATE

SYMBOL: radix
SYMBOL: negative?

: string>natural ( seq radix -- n/f )
    over empty? [ 2drop f ] [
        [ [ digit> ] dip (digits>integer) ] each-digit
    ] if ; inline

: sign ( -- str ) negative? get "-" "+" ? ;

: with-radix ( radix quot -- )
    radix swap with-variable ; inline

: (base>) ( str -- n ) radix get base> ;

: whole-part ( str -- m n )
    sign split1 [ (base>) ] dip
    dup [ (base>) ] [ drop 0 swap ] if ;

: string>ratio ( str radix -- a/b )
    [
        "-" ?head dup negative? set swap
        "/" split1 (base>) [ whole-part ] dip
        3dup and and [ / + swap [ neg ] when ] [ 2drop 2drop f ] if
    ] with-radix ;

: string>integer ( str radix -- n/f )
    over first-unsafe CHAR: - = [
        [ rest-slice ] dip string>natural dup [ neg ] when
    ] [
        string>natural
    ] if ; inline

: string>float ( str -- n/f )
    [ CHAR: , eq? not ] filter
    >byte-array 0 suffix (string>float) ;

: number-char? ( char -- ? )
    "0123456789ABCDEFabcdef." member? ;

: numeric-looking? ( str -- ? )
    "-" ?head drop
    dup empty? [ drop f ] [
        dup first number-char? [
            last number-char?
        ] [ drop f ] if
    ] if ;

PRIVATE>

: base> ( str radix -- n/f )
    over numeric-looking? [
        over [ "/." member? ] find nip {
            { CHAR: / [ string>ratio ] }
            { CHAR: . [ drop string>float ] }
            [ drop string>integer ]
        } case
    ] [ 2drop f ] if ;

: string>number ( str -- n/f ) 10 base> ;
: bin> ( str -- n/f ) 2 base> ;
: oct> ( str -- n/f ) 8 base> ;
: hex> ( str -- n/f ) 16 base> ;

: >digit ( n -- ch )
    dup 10 < [ CHAR: 0 + ] [ 10 - CHAR: a + ] if ;

: positive>base ( num radix -- str )
    dup 1 <= [ "Invalid radix" throw ] when
    [ dup 0 > ] swap [ /mod >digit ] curry "" produce-as nip
    dup reverse-here ; inline

PRIVATE>

GENERIC# >base 1 ( n radix -- str )

<PRIVATE

: (>base) ( n -- str ) radix get positive>base ;

PRIVATE>

M: integer >base
    over 0 = [
        2drop "0"
    ] [
        over 0 > [
            positive>base
        ] [
            [ neg ] dip positive>base CHAR: - prefix
        ] if
    ] if ;

M: ratio >base
    [
        dup 0 < negative? set
        abs 1 /mod
        [ [ "" ] [ (>base) sign append ] if-zero ]
        [
            [ numerator (>base) ]
            [ denominator (>base) ] bi
            "/" glue
        ] bi* append
        negative? get [ CHAR: - prefix ] when
    ] with-radix ;

: fix-float ( str -- newstr )
    {
        {
            [ CHAR: e over member? ]
            [ "e" split1 [ fix-float "e" ] dip 3append ]
        } {
            [ CHAR: . over member? ]
            [ ]
        }
        [ ".0" append ]
    } cond ;

: float>string ( n -- str )
    (float>string)
    [ 0 = ] trim-tail >string
    fix-float ;

M: float >base
    drop {
        { [ dup fp-nan? ] [ drop "0/0." ] }
        { [ dup 1/0. = ] [ drop "1/0." ] }
        { [ dup -1/0. = ] [ drop "-1/0." ] }
        { [ dup double>bits HEX: 8000000000000000 = ] [ drop "-0.0" ] }
        [ float>string ]
    } cond ;

: number>string ( n -- str ) 10 >base ;
: >bin ( n -- str ) 2 >base ;
: >oct ( n -- str ) 8 >base ;
: >hex ( n -- str ) 16 >base ;

: # ( n -- ) number>string % ;
