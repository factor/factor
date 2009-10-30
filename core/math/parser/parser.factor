! Copyright (C) 2004, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math.private namespaces sequences sequences.private
strings arrays combinators splitting math assocs byte-arrays make ;
IN: math.parser

: digit> ( ch -- n )
    127 bitand {
        { [ dup CHAR: 9 <= ] [ CHAR: 0 - ] }
        { [ dup CHAR: a <  ] [ CHAR: A 10 - - ] }
        [ CHAR: a 10 - - ]
    } cond
    dup 0 < [ drop 255 ] [ dup 16 >= [ drop 255 ] when ] if ; inline

: string>digits ( str -- digits )
    [ digit> ] B{ } map-as ; inline

: (digits>integer) ( valid? accum digit radix -- valid? accum )
    2dup < [ swapd * + ] [ 2drop 2drop f 0 ] if ; inline

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
        [ over CHAR: , eq? [ 2drop ] [ [ digit> ] dip (digits>integer) ] if ] each-digit
    ] if ;

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

: dec>float ( str -- n/f )
    [ CHAR: , eq? not ] BV{ } filter-as
    0 over push B{ } like (string>float) ;

: hex>float-parts ( str -- neg? mantissa-str expt )
    "-" ?head swap "p" split1 [ 10 base> ] [ 0 ] if* ; inline

: make-mantissa ( str -- bits )
    16 base> dup log2 52 swap - shift ; inline

: combine-hex-float-parts ( neg? mantissa expt -- float )
    dup 2046 > [ 2drop -1/0. 1/0. ? ] [
        dup 0 <= [ 1 - shift 0 ] when
        [ HEX: 8000,0000,0000,0000 0 ? ]
        [ 52 2^ 1 - bitand ]
        [ 52 shift ] tri* bitor bitor
        bits>double 
    ] if ; inline

: hex>float ( str -- n/f )
    hex>float-parts
    [ "." split1 [ append make-mantissa ] [ drop 16 base> log2 ] 2bi ]
    [ + 1023 + ] bi*
    combine-hex-float-parts ;

: base>float ( str base -- n/f )
    {
        { 16 [ hex>float ] }
        [ drop dec>float ]
    } case ; inline

: number-char? ( char -- ? )
    "0123456789ABCDEFabcdef." member? ; inline

: last-unsafe ( seq -- elt )
    [ length 1 - ] [ nth-unsafe ] bi ; inline

: numeric-looking? ( str -- ? )
    dup empty? [ drop f ] [
        dup first-unsafe number-char? [
            last-unsafe number-char?
        ] [
            dup first-unsafe CHAR: - eq? [
                dup length 1 eq? [ drop f ] [
                    1 over nth-unsafe number-char? [
                        last-unsafe number-char?
                    ] [ drop f ] if
                ] if
            ] [ drop f ] if
        ] if
    ] if ; inline

PRIVATE>

: string>float ( str -- n/f )
    10 base>float ; inline

: base> ( str radix -- n/f )
    over numeric-looking? [
        over [ "/." member? ] find nip {
            { CHAR: / [ string>ratio ] }
            { CHAR: . [ base>float ] }
            [ drop string>integer ]
        } case
    ] [ 2drop f ] if ;

: string>number ( str -- n/f ) 10 base> ; inline
: bin> ( str -- n/f ) 2 base> ; inline
: oct> ( str -- n/f ) 8 base> ; inline
: hex> ( str -- n/f ) 16 base> ; inline

: >digit ( n -- ch )
    dup 10 < [ CHAR: 0 + ] [ 10 - CHAR: a + ] if ; inline

: positive>base ( num radix -- str )
    dup 1 <= [ "Invalid radix" throw ] when
    [ dup 0 > ] swap [ /mod >digit ] curry "" produce-as nip
    reverse! ; inline

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

<PRIVATE

: mantissa-expt-normalize ( mantissa expt -- mantissa' expt' )
    dup zero?
    [ over log2 52 swap - [ shift 52 2^ 1 - bitand ] [ 1022 + - ] bi-curry bi* ]
    [ 1023 - ] if ;

: mantissa-expt ( float -- mantissa expt )
    [ 52 2^ 1 - bitand ]
    [ -0.0 double>bits bitnot bitand -52 shift ] bi
    mantissa-expt-normalize ;

: float>hex-sign ( bits -- str )
    -0.0 double>bits bitand zero? "" "-" ? ;

: float>hex-value ( mantissa -- str )
    16 >base 13 CHAR: 0 pad-head [ CHAR: 0 = ] trim-tail
    [ "0" ] [ ] if-empty "1." prepend ;

: float>hex-expt ( mantissa -- str )
    10 >base "p" prepend ;

: float>hex ( n -- str )
    double>bits
    [ float>hex-sign ] [
        mantissa-expt [ float>hex-value ] [ float>hex-expt ] bi*
    ] bi 3append ;

: float>decimal ( n -- str )
    (float>string)
    [ 0 = ] trim-tail >string
    fix-float ;

: float>base ( n base -- str )
    {
        { 16 [ float>hex ] }
        [ drop float>decimal ]
    } case ; inline

PRIVATE>

: float>string ( n -- str )
    10 float>base ; inline

M: float >base
    {
        { [ over fp-nan? ] [ 2drop "0/0." ] }
        { [ over 1/0. =  ] [ 2drop "1/0." ] }
        { [ over -1/0. = ] [ 2drop "-1/0." ] }
        { [ over  0.0 fp-bitwise= ] [ 2drop  "0.0" ] }
        { [ over -0.0 fp-bitwise= ] [ 2drop "-0.0" ] }
        [ float>base ]
    } cond ;

: number>string ( n -- str ) 10 >base ; inline
: >bin ( n -- str ) 2 >base ; inline
: >oct ( n -- str ) 8 >base ; inline
: >hex ( n -- str ) 16 >base ; inline

: # ( n -- ) number>string % ; inline
