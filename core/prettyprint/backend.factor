! Copyright (C) 2003, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: prettyprint-internals
USING: arrays byte-arrays bit-arrays generic hashtables io
kernel math namespaces parser sequences strings sbufs styles
vectors words prettyprint ;

GENERIC: pprint* ( obj -- )

! Atoms
: word-style ( word -- style )
    [
        dup presented set
        parsing? [ bold font-style set ] when
    ] make-hash ;

: pprint-word ( word -- )
    dup word-name [ "( no name )" ] unless*
    swap word-style styled-text ;

M: word pprint*
    dup parsing? [
        <flow \ POSTPONE: pprint-word pprint-word block>
    ] [
        pprint-word
    ] if ;

M: real pprint* number>string text ;

M: f pprint* drop \ f pprint-word ;

! Strings
: ch>ascii-escape ( ch -- str )
    H{
        { CHAR: \e "\\e"  }
        { CHAR: \n "\\n"  }
        { CHAR: \r "\\r"  }
        { CHAR: \t "\\t"  }
        { CHAR: \0 "\\0"  }
        { CHAR: \\ "\\\\" }
        { CHAR: \" "\\\"" }
    } hash ;

: ch>unicode-escape ( ch -- str )
    >hex 4 CHAR: 0 pad-left "\\u" swap append ;

: unparse-ch ( ch -- )
    dup quotable? [
        ,
    ] [
        dup ch>ascii-escape [ ] [ ch>unicode-escape ] ?if %
    ] if ;

: do-string-limit ( str -- trimmed )
    string-limit get [
        dup length margin get > [
            margin get 3 - head "..." append
        ] when
    ] when ;

: string-style
    H{ { foreground { 0.3 0.3 0.3 1.0 } } } ;

: pprint-string ( str prefix -- )
    >r do-string-limit r>
    [ % [ unparse-ch ] each CHAR: " , ] "" make
    string-style styled-text ;

M: string pprint* "\"" pprint-string ;

M: sbuf pprint* "SBUF\" " pprint-string ;

! Sequences
: nesting-limit? ( -- ? )
    nesting-limit get dup [ pprinter-stack get length < ] when ;

: presentation-text ( str obj -- )
    presented associate styled-text ;

: check-recursion ( obj quot -- )
    nesting-limit? [
        drop "#" swap presentation-text
    ] [
        over recursion-check get memq? [
            drop "&" swap presentation-text
        ] [
            over recursion-check get push
            call
            recursion-check get pop*
        ] if
    ] if ; inline

: length-limit? ( seq -- trimmed ? )
    length-limit get dup
    [ over length over > [ head t ] [ drop f ] if ]
    [ drop f ] if ;

: pprint-hilite ( object n -- )
    hilite-index get = [
        <hilite pprint* block>
    ] [
        pprint*
    ] if ;

: pprint-elements ( seq -- )
    length-limit? >r dup hilite-quotation get eq? [
        dup length [ pprint-hilite ] 2each
    ] [
        [ pprint* ] each
    ] if r> [ "..." text ] when ;

GENERIC: pprint-delims ( obj -- start end )

M: complex pprint-delims drop \ C{ \ } ;
M: quotation pprint-delims drop \ [ \ ] ;
M: array pprint-delims drop \ { \ } ;
M: byte-array pprint-delims drop \ B{ \ } ;
M: bit-array pprint-delims drop \ ?{ \ } ;
M: vector pprint-delims drop \ V{ \ } ;
M: hashtable pprint-delims drop \ H{ \ } ;
M: tuple pprint-delims drop \ T{ \ } ;
M: wrapper pprint-delims drop \ W{ \ } ;

GENERIC: >pprint-sequence ( obj -- seq )

M: object >pprint-sequence ;

M: bit-array >pprint-sequence ;
M: complex >pprint-sequence >rect 2array ;
M: hashtable >pprint-sequence hash>alist ;
M: tuple >pprint-sequence tuple>array ;
M: wrapper >pprint-sequence wrapped 1array ;

GENERIC: pprint-narrow? ( obj -- ? )

M: object pprint-narrow? drop f ;

M: array pprint-narrow? drop t ;
M: vector pprint-narrow? drop t ;
M: hashtable pprint-narrow? drop t ;
M: tuple pprint-narrow? drop t ;

: pprint-object ( obj -- )
    [
        <flow
        dup pprint-delims >r pprint-word
        dup pprint-narrow? [ <narrow ] [ <inset ] if
        >pprint-sequence pprint-elements
        block> r> pprint-word block>
    ] check-recursion ;
    
M: object pprint* pprint-object ;

M: wrapper pprint*
    dup wrapped word? [
        <flow \ \ pprint-word wrapped pprint-word block>
    ] [
        pprint-object
    ] if ;
