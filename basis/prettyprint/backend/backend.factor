! Copyright (C) 2003, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays byte-arrays generic hashtables io assocs
kernel math namespaces make sequences strings sbufs vectors
words prettyprint.config prettyprint.custom prettyprint.sections
quotations io io.pathnames io.styles math.parser effects
classes.tuple math.order classes.tuple.private classes
combinators colors ;
IN: prettyprint.backend

M: effect pprint* effect>string "(" ")" surround text ;

: ?effect-height ( word -- n )
    stack-effect [ effect-height ] [ 0 ] if* ;

: ?start-group ( word -- )
    ?effect-height 0 > [ start-group ] when ;

: ?end-group ( word -- )
    ?effect-height 0 < [ end-group ] when ;

! Atoms
: word-style ( word -- style )
    dup "word-style" word-prop >hashtable [
        [
            [ presented set ]
            [
                [ parsing-word? ] [ delimiter? ] [ t eq? ] tri or or
                [ bold font-style set ] when
            ] bi
        ] bind
    ] keep ;

: word-name* ( word -- str )
    name>> "( no name )" or ;

: pprint-word ( word -- )
    [ record-vocab ]
    [ [ word-name* ] [ word-style ] bi styled-text ] bi ;

: pprint-prefix ( word quot -- )
    <block swap pprint-word call block> ; inline

M: parsing-word pprint*
    \ POSTPONE: [ pprint-word ] pprint-prefix ;

M: word pprint*
    [ pprint-word ] [ ?start-group ] [ ?end-group ] tri ;

M: method-body pprint*
    [
        [
            [ "M\\ " % "method-class" word-prop word-name* % ]
            [ " " % "method-generic" word-prop word-name* % ] bi
        ] "" make
    ] [ word-style ] bi styled-text ;

M: real pprint* number>string text ;

M: f pprint* drop \ f pprint-word ;

! Strings
: ch>ascii-escape ( ch -- str )
    H{
        { CHAR: \a CHAR: a  }
        { CHAR: \e CHAR: e  }
        { CHAR: \n CHAR: n  }
        { CHAR: \r CHAR: r  }
        { CHAR: \t CHAR: t  }
        { CHAR: \0 CHAR: 0  }
        { CHAR: \\ CHAR: \\ }
        { CHAR: \" CHAR: \" }
    } at ;

: unparse-ch ( ch -- )
    dup ch>ascii-escape [ "\\" % ] [ ] ?if , ;

: do-string-limit ( str -- trimmed )
    string-limit? get [
        dup length margin get > [
            margin get 3 - head "..." append
        ] when
    ] when ;

: string-style ( obj -- hash )
    [
        presented set
        T{ rgba f 0.3 0.3 0.3 1.0 } foreground set
    ] H{ } make-assoc ;

: unparse-string ( str prefix suffix -- str )
    [ [ % do-string-limit [ unparse-ch ] each ] dip % ] "" make ;

: pprint-string ( obj str prefix suffix -- )
    unparse-string swap string-style styled-text ;

M: string pprint*
    dup "\"" "\"" pprint-string ;

M: sbuf pprint*
    dup "SBUF\" " "\"" pprint-string ;

M: pathname pprint*
    dup string>> "P\" " "\"" pprint-string ;

! Sequences
: nesting-limit? ( -- ? )
    nesting-limit get dup [ pprinter-stack get length < ] when ;

: present-text ( str obj -- )
    presented associate styled-text ;

: check-recursion ( obj quot -- )
    nesting-limit? [
        drop
        "~" over class name>> "~" 3append
        swap present-text
    ] [
        over recursion-check get memq? [
            drop "~circularity~" swap present-text
        ] [
            over recursion-check get push
            call
            recursion-check get pop*
        ] if
    ] if ; inline

: tuple>assoc ( tuple -- assoc )
    [ class all-slots ] [ tuple-slots ] bi zip
    [ [ initial>> ] dip = not ] assoc-filter
    [ [ name>> ] dip ] assoc-map ;

: pprint-slot-value ( name value -- )
    <flow \ { pprint-word
    [ text ] [ f <inset pprint* block> ] bi*
    \ } pprint-word block> ;

M: tuple pprint*
    boa-tuples? get [ call-next-method ] [
        [
            <flow
            \ T{ pprint-word
            dup class pprint-word
            t <inset
            tuple>assoc [ pprint-slot-value ] assoc-each
            block>
            \ } pprint-word
            block>
        ] check-recursion
    ] if ;

: do-length-limit ( seq -- trimmed n/f )
    length-limit get dup [
        over length over [-]
        dup zero? [ 2drop f ] [ [ head ] dip ] if
    ] when ;

: pprint-elements ( seq -- )
    do-length-limit
    [ [ pprint* ] each ] dip
    [ "~" swap number>string " more~" 3append text ] when* ;

M: quotation pprint-delims drop \ [ \ ] ;
M: curry pprint-delims drop \ [ \ ] ;
M: compose pprint-delims drop \ [ \ ] ;
M: array pprint-delims drop \ { \ } ;
M: byte-array pprint-delims drop \ B{ \ } ;
M: vector pprint-delims drop \ V{ \ } ;
M: hashtable pprint-delims drop \ H{ \ } ;
M: tuple pprint-delims drop \ T{ \ } ;
M: wrapper pprint-delims drop \ W{ \ } ;
M: callstack pprint-delims drop \ CS{ \ } ;

M: object >pprint-sequence ;
M: vector >pprint-sequence ;
M: curry >pprint-sequence ;
M: compose >pprint-sequence ;
M: hashtable >pprint-sequence >alist ;
M: wrapper >pprint-sequence wrapped>> 1array ;
M: callstack >pprint-sequence callstack>array ;

M: tuple >pprint-sequence
    [ class ] [ tuple-slots ] bi
    [ 1array ] [ [ f 2array ] dip append ] if-empty ;

M: object pprint-narrow? drop f ;
M: array pprint-narrow? drop t ;
M: vector pprint-narrow? drop t ;
M: hashtable pprint-narrow? drop t ;
M: tuple pprint-narrow? drop t ;

M: object pprint-object ( obj -- )
    [
        <flow
        dup pprint-delims [
            pprint-word
            dup pprint-narrow? <inset
            >pprint-sequence pprint-elements
            block>
        ] dip pprint-word block>
    ] check-recursion ;

M: object pprint* pprint-object ;
M: vector pprint* pprint-object ;
M: hashtable pprint* pprint-object ;
M: curry pprint* pprint-object ;
M: compose pprint* pprint-object ;

M: wrapper pprint*
    {
        { [ dup wrapped>> method-body? ] [ wrapped>> pprint* ] }
        { [ dup wrapped>> word? ] [ <block \ \ pprint-word wrapped>> pprint-word block> ] }
        [ pprint-object ]
    } cond ;
