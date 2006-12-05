! Copyright (C) 2003, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: prettyprint-internals
USING: alien arrays generic hashtables io kernel math
namespaces parser sequences strings styles vectors words
prettyprint ;

GENERIC: pprint* ( obj -- )

! Atoms
M: byte-array pprint* drop "( byte array )" text ;

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
        H{ } <flow \ POSTPONE: pprint-word pprint-word block>
    ] [
        pprint-word
    ] if ;

M: real pprint* number>string text ;

M: f pprint* drop \ f pprint-word ;

M: alien pprint*
    dup expired? [
        drop "( alien expired )"
    ] [
        \ ALIEN: pprint-word alien-address number>string
    ] if text ;

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

: pprint-string ( str prefix -- )
    [ % [ unparse-ch ] each CHAR: " , ] "" make
    do-string-limit text ;

M: string pprint* "\"" pprint-string ;

M: sbuf pprint* "SBUF\" " pprint-string ;

M: dll pprint*
    dll-path alien>char-string "DLL\" " pprint-string ;

! Sequences
: nesting-limit? ( -- ? )
    nesting-limit get dup [ pprinter-stack get length < ] when ;

: truncated-nesting ( obj str -- )
    swap presented associate styled-text ;

: check-recursion ( obj quot -- )
    nesting-limit? [
        drop "#" truncated-nesting
    ] [
        over recursion-check get memq? [
            drop "&" truncated-nesting
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

: hilite-style ( -- hash )
    H{
        { background { 0.9 0.9 0.9 1 } }
        { highlight t }
    } ;

: pprint-hilite ( object n -- )
    hilite-index get = [
        hilite-style <flow pprint* block>
    ] [
        pprint*
    ] if ;

: pprint-elements ( seq -- )
    length-limit? >r dup hilite-quotation get eq? [
        dup length [ pprint-hilite ] 2each
    ] [
        [ pprint* ] each
    ] if r> [ "..." text ] when ;

GENERIC: >pprint-sequence ( obj -- seq start end narrow? )

M: complex >pprint-sequence >rect 2array \ C{ \ } f ;

M: quotation >pprint-sequence \ [ \ ] f ;

M: array >pprint-sequence \ { \ } t ;

M: vector >pprint-sequence \ V{ \ } t ;

M: hashtable >pprint-sequence hash>alist \ H{ \ } t ;

M: tuple >pprint-sequence tuple>array \ T{ \ } t ;

M: wrapper >pprint-sequence wrapped 1array \ W{ \ } f ;

: pprint-object ( obj -- )
    [
        >pprint-sequence H{ } <flow
        rot [ pprint-word ] when*
        [ H{ } <narrow ] [ H{ } <inset ] if
        swap pprint-elements
        block> [ pprint-word ] when* block>
    ] check-recursion ;
    
M: object pprint* pprint-object ;

M: wrapper pprint*
    dup wrapped word? [
        \ \ pprint-word wrapped pprint-word
    ] [
        pprint-object
    ] if ;
