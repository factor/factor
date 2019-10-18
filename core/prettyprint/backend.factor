! Copyright (C) 2003, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays byte-arrays bit-arrays generic hashtables io assocs
kernel math namespaces sequences strings sbufs styles
vectors words prettyprint quotations io ;
IN: prettyprint-internals

GENERIC: pprint* ( obj -- )

: ?effect-height ( word -- n )
    stack-effect [ effect-height ] [ 0 ] if* ;

: ?start-group ( word -- )
    ?effect-height 0 > [ start-group ] when ;

: ?end-group ( word -- )
    ?effect-height 0 < [ end-group ] when ;

\ >r hard "break-before" set-word-prop
\ r> hard "break-after" set-word-prop

! Atoms
: word-style ( word -- style )
    [
        dup presented set
        dup parsing? over delimiter? rot t eq? or or
        [ bold font-style set ] when
    ] H{ } make-assoc ;

: word-name* ( word -- str )
    word-name [ "( no name )" ] unless* ;

: pprint-word ( word -- )
    dup record-vocab
    dup word-name* over word-style styled-text
    dup ?start-group ?end-group ;

M: word pprint*
    dup parsing? [
        <block \ POSTPONE: pprint-word pprint-word block>
    ] [
        dup "break-before" word-prop break
        dup pprint-word
        "break-after" word-prop break
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
    } at ;

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

: string-style ( obj -- hash )
    [
        presented set
        { 0.3 0.3 0.3 1.0 } foreground set
    ] H{ } make-assoc ;

: unparse-string ( str prefix -- str )
    [
        % do-string-limit [ unparse-ch ] each CHAR: " ,
    ] "" make ;

: pprint-string ( obj str prefix -- )
    unparse-string swap string-style styled-text ;

M: string pprint* dup "\"" pprint-string ;

M: sbuf pprint* dup "SBUF\" " pprint-string ;

M: pathname pprint* dup pathname-string "P\" " pprint-string ;

! Sequences
: nesting-limit? ( -- ? )
    nesting-limit get dup [ pprinter-stack get length < ] when ;

: present-text ( str obj -- )
    presented associate styled-text ;

: check-recursion ( obj quot -- )
    nesting-limit? [
        drop "( ... )" swap present-text
    ] [
        over recursion-check get memq? [
            drop "( circularity )" swap present-text
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

: pprint-hilite ( n object -- )
    pprint* hilite-index get = [ hilite ] when ;

: pprint-elements ( seq -- )
    length-limit? >r dup hilite-quotation get eq? [
        [ length ] keep [ pprint-hilite ] 2each
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
M: hashtable >pprint-sequence >alist ;
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
        dup pprint-narrow? <inset
        >pprint-sequence pprint-elements
        block> r> pprint-word block>
    ] check-recursion ;
    
M: object pprint* pprint-object ;

M: wrapper pprint*
    dup wrapped word? [
        <block \ \ pprint-word wrapped pprint-word block>
    ] [
        pprint-object
    ] if ;
