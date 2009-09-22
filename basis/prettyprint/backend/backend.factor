! Copyright (C) 2003, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs byte-arrays byte-vectors classes
classes.tuple classes.tuple.private colors colors.constants
combinators continuations effects generic hashtables io
io.pathnames io.styles kernel make math math.order math.parser
namespaces prettyprint.config prettyprint.custom
prettyprint.sections prettyprint.stylesheet quotations sbufs
sequences strings vectors words words.symbol ;
IN: prettyprint.backend

M: effect pprint* effect>string "(" ")" surround text ;

: ?effect-height ( word -- n )
    stack-effect [ effect-height ] [ 0 ] if* ;

: ?start-group ( word -- )
    ?effect-height 0 > [ start-group ] when ;

: ?end-group ( word -- )
    ?effect-height 0 < [ end-group ] when ;

! Atoms
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

M: real pprint*
    number-base get {
        { 16 [ \ HEX: [ 16 >base text ] pprint-prefix ] }
        {  8 [ \ OCT: [  8 >base text ] pprint-prefix ] }
        {  2 [ \ BIN: [  2 >base text ] pprint-prefix ] }
        [ drop number>string text ]
    } case ;

M: float pprint*
    dup fp-nan? [
        \ NAN: [ fp-nan-payload >hex text ] pprint-prefix
    ] [
        number-base get {
            { 16 [ \ HEX: [ 16 >base text ] pprint-prefix ] }
            [ drop number>string text ]
        } case
    ] if ;

M: f pprint* drop \ f pprint-word ;

: pprint-effect ( effect -- )
    [ effect>string ] [ effect-style ] bi styled-text ;

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

: filter-tuple-assoc ( slot,value -- name,value )
    [ [ initial>> ] dip = not ] assoc-filter
    [ [ name>> ] dip ] assoc-map ;

: tuple>assoc ( tuple -- assoc )
    [ class all-slots ] [ tuple-slots ] bi zip filter-tuple-assoc ;

: pprint-slot-value ( name value -- )
    <flow \ { pprint-word
    [ text ] [ f <inset pprint* block> ] bi*
    \ } pprint-word block> ;

: (pprint-tuple) ( opener class slots closer -- )
    <flow {
        [ pprint-word ]
        [ pprint-word ]
        [ t <inset [ pprint-slot-value ] assoc-each block> ]
        [ pprint-word ]
    } spread block> ;

: ?pprint-tuple ( tuple quot -- )
    [ boa-tuples? get [ pprint-object ] ] dip [ check-recursion ] curry if ; inline

: pprint-tuple ( tuple -- )
    [ [ \ T{ ] dip [ class ] [ tuple>assoc ] bi \ } (pprint-tuple) ] ?pprint-tuple ;

M: tuple pprint*
    pprint-tuple ;

: recover-pprint ( try recovery -- )
    pprinter-stack get clone
    [ pprinter-stack set ] curry prepose recover ; inline

: pprint-c-object ( object content-quot pointer-quot -- )
    [ c-object-pointers? get ] 2dip
    [ nip ]
    [ [ drop ] prepose [ recover-pprint ] 2curry ] 2bi if ; inline

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
M: byte-vector pprint-delims drop \ BV{ \ } ;
M: vector pprint-delims drop \ V{ \ } ;
M: hashtable pprint-delims drop \ H{ \ } ;
M: tuple pprint-delims drop \ T{ \ } ;
M: wrapper pprint-delims drop \ W{ \ } ;
M: callstack pprint-delims drop \ CS{ \ } ;

M: object >pprint-sequence ;
M: vector >pprint-sequence ;
M: byte-vector >pprint-sequence ;
M: callable >pprint-sequence ;
M: hashtable >pprint-sequence >alist ;
M: wrapper >pprint-sequence wrapped>> 1array ;
M: callstack >pprint-sequence callstack>array ;

: class-slot-sequence ( class slots -- sequence )
    [ 1array ] [ [ f 2array ] dip append ] if-empty ;

M: tuple >pprint-sequence
    [ class ] [ tuple-slots ] bi class-slot-sequence ;

M: object pprint-narrow? drop f ;
M: byte-vector pprint-narrow? drop f ;
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
M: byte-vector pprint* pprint-object ;
M: hashtable pprint* pprint-object ;
M: curry pprint* pprint-object ;
M: compose pprint* pprint-object ;

M: wrapper pprint*
    {
        { [ dup wrapped>> method-body? ] [ wrapped>> pprint* ] }
        { [ dup wrapped>> word? ] [ <block \ \ pprint-word wrapped>> pprint-word block> ] }
        [ pprint-object ]
    } cond ;
