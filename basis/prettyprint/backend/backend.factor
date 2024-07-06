! Copyright (C) 2003, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs byte-arrays byte-vectors classes
classes.algebra.private classes.maybe classes.private
classes.tuple combinators combinators.short-circuit
continuations effects generic hash-sets hashtables io.pathnames
io.styles kernel lists make math math.order math.parser
namespaces prettyprint.config prettyprint.custom
prettyprint.sections prettyprint.stylesheet quotations sbufs
sequences strings vectors words ;
QUALIFIED: sets
IN: prettyprint.backend

M: effect pprint* effect>string text ;

: ?effect-height ( word -- n )
    stack-effect [ effect-height ] [ 0 ] if* ;

: ?start-group ( word -- )
    ?effect-height 0 > [ start-group ] when ;

: ?end-group ( word -- )
    ?effect-height 0 < [ end-group ] when ;

! Atoms
GENERIC: word-name* ( obj -- str )

M: maybe word-name*
    class-name "maybe{ " " }" surround ;

M: anonymous-complement word-name*
    class-name "not{ " " }" surround ;

M: anonymous-union word-name*
    class-name "union{ " " }" surround ;

M: anonymous-intersection word-name*
    class-name "intersection{ " " }" surround ;

: ?qualified-name ( word -- name )
    [ name>> ] keep qualified-names? get [
        vocabulary>> [ ":" rot 3append ] when*
    ] [ drop ] if ;

M: word word-name*
    [ ?qualified-name "( no name )" or ] [ record-vocab ] bi ;

: pprint-word ( word -- )
    [ word-name* ] [ word-style ] bi styled-text ;

GENERIC: pprint-class ( obj -- )

M: classoid pprint-class pprint* ;

M: class pprint-class \ f or pprint-word ;

M: word pprint-class pprint-word ;

: pprint-prefix ( word quot -- )
    <block swap pprint-word call block> ; inline

M: parsing-word pprint*
    \ POSTPONE: [ pprint-word ] pprint-prefix ;

M: word pprint*
    [ pprint-word ] [ ?start-group ] [ ?end-group ] tri ;

M: method pprint*
    <block
    [ \ M\ pprint-word "method-class" word-prop pprint* ]
    [ "method-generic" word-prop pprint-word ] bi
    block> ;

: pprint-prefixed-number ( n quot: ( n -- n' ) pre -- )
    pick neg?
    [ [ neg ] [ call ] [ prepend ] tri* "-" prepend text ]
    [ [ call ] [ prepend ] bi* text ] if ; inline

ERROR: unsupported-number-base n base ;

M: real pprint*
    number-base get {
        { 10 [ number>string text ] }
        { 16 [ [ >hex ] "0x" pprint-prefixed-number ] }
        {  8 [ [ >oct ] "0o" pprint-prefixed-number ] }
        {  2 [ [ >bin ] "0b" pprint-prefixed-number ] }
        [ unsupported-number-base ]
    } case ;

M: float pprint*
    {
        { [ dup 0/0. fp-bitwise= ] [ drop "0/0." text ] }
        { [ dup -0/0. fp-bitwise= ] [ drop "-0/0." text ] }
        { [ dup fp-nan? ] [
            \ NAN: [
                [ fp-nan-payload ] [ fp-sign ] bi
                [ 0xfffffffffffff bitxor 1 + neg ] when >hex text
            ] pprint-prefix
        ] }
        { [ dup 1/0. = ] [ drop "1/0." text ] }
        { [ dup -1/0. = ] [ drop "-1/0." text ] }
        { [ dup 0.0 fp-bitwise= ] [ drop "0.0" text ] }
        { [ dup -0.0 fp-bitwise= ] [ drop "-0.0" text ] }
        [ call-next-method ]
    } cond ;

M: f pprint* drop \ f pprint-word ;

: pprint-effect ( effect -- )
    [ effect>string ] [ effect-style ] bi styled-text ;

! Strings
: ch>ascii-escape ( ch -- ch' ? )
    H{
        { CHAR: \a CHAR: a  }
        { CHAR: \b CHAR: b  }
        { CHAR: \e CHAR: e  }
        { CHAR: \f CHAR: f  }
        { CHAR: \n CHAR: n  }
        { CHAR: \r CHAR: r  }
        { CHAR: \t CHAR: t  }
        { CHAR: \v CHAR: v  }
        { CHAR: \0 CHAR: 0  }
        { CHAR: \\ CHAR: \\ }
        { CHAR: \" CHAR: \" }
    } ?at ; inline

: unparse-ch ( ch -- )
    ch>ascii-escape [ CHAR: \\ , , ] [
        dup 32 < [ dup 16 < "\\x0" "\\x" ? % >hex % ] [ , ] if
    ] if ;

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

: check-recursion ( obj quot: ( obj -- ) -- )
    nesting-limit? [
        drop
        [ class-of name>> "~" 1surround ] keep present-text
    ] [
        over recursion-check get member-eq? [
            drop "~circularity~" swap present-text
        ] [
            over recursion-check get push
            call
            recursion-check get pop*
        ] if
    ] if ; inline

: filter-tuple-assoc ( slot,value -- name,value )
    [ [ initial>> ] dip = ] assoc-reject
    [ [ name>> ] dip ] assoc-map ;

: tuple>assoc ( tuple -- assoc )
    [ class-of all-slots ] [ tuple-slots ] bi zip filter-tuple-assoc ;

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
    [ [ \ T{ ] dip [ class-of ] [ tuple>assoc ] bi \ } (pprint-tuple) ] ?pprint-tuple ;

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
        1 - over length over [-]
        dup 1 > [ [ head-slice ] dip ] [ 2drop f ] if
    ] when ;

: pprint-elements ( seq -- )
    do-length-limit
    [ [ pprint* ] each ] dip
    [ number>string "~" " more~" surround text ] when* ;

M: quotation pprint-delims drop \ [ \ ] ;
M: curried pprint-delims drop \ [ \ ] ;
M: composed pprint-delims drop \ [ \ ] ;
M: array pprint-delims drop \ { \ } ;
M: byte-array pprint-delims drop \ B{ \ } ;
M: byte-vector pprint-delims drop \ BV{ \ } ;
M: vector pprint-delims drop \ V{ \ } ;
M: cons-state pprint-delims drop \ L{ \ } ;
M: +nil+ pprint-delims drop \ L{ \ } ;
M: hashtable pprint-delims drop \ H{ \ } ;
M: tuple pprint-delims drop \ T{ \ } ;
M: wrapper pprint-delims drop \ W{ \ } ;
M: callstack pprint-delims drop \ CS{ \ } ;
M: hash-set pprint-delims drop \ HS{ \ } ;
M: anonymous-union pprint-delims drop \ union{ \ } ;
M: anonymous-intersection pprint-delims drop \ intersection{ \ } ;
M: anonymous-complement pprint-delims drop \ not{ \ } ;
M: anonymous-predicate pprint-delims drop \ predicate{ \ } ;
M: maybe pprint-delims drop \ maybe{ \ } ;

M: object >pprint-sequence ;
M: vector >pprint-sequence ;
M: byte-vector >pprint-sequence ;
M: callable >pprint-sequence ;
M: hashtable >pprint-sequence >alist ;
M: wrapper >pprint-sequence wrapped>> 1array ;
M: callstack >pprint-sequence callstack>array ;
M: hash-set >pprint-sequence sets:members ;
M: anonymous-union >pprint-sequence members>> ;
M: anonymous-intersection >pprint-sequence participants>> ;
M: anonymous-complement >pprint-sequence class>> 1array ;
M: anonymous-predicate >pprint-sequence [ class>> ] [ predicate>> ] bi 2array ;
M: maybe >pprint-sequence class>> 1array ;

: class-slot-sequence ( class slots -- sequence )
    [ 1array ] [ [ f 2array ] dip append ] if-empty ;

M: tuple >pprint-sequence
    [ class-of ] [ tuple-slots ] bi class-slot-sequence ;

M: object pprint-narrow? drop f ;
M: byte-vector pprint-narrow? drop f ;
M: array pprint-narrow? drop t ;
M: vector pprint-narrow? drop t ;
M: hashtable pprint-narrow? drop t ;
M: tuple pprint-narrow? drop t ;

M: object pprint-object
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

M: cons-state pprint*
    [
        <flow
        dup pprint-delims [
            pprint-word
            dup pprint-narrow? <inset
            [
                building get
                length-limit get
                '[ dup cons-state? _ length _ < and ]
                [ uncons swap , ] while
            ] { } make
            [ pprint* ] each
            dup list? [
                nil? [ "~more~" text ] unless
            ] [
                "." text pprint*
            ] if
            block>
        ] dip pprint-word block>
    ] check-recursion ;

M: +nil+ pprint*
    <flow pprint-delims [ pprint-word ] bi@ block> ;

: with-extra-nesting-level ( quot -- )
    nesting-limit [ dup [ 1 + ] [ f ] if* ] change
    [ nesting-limit set ] curry finally ; inline

M: hashtable pprint*
    [ pprint-object ] with-extra-nesting-level ;
M: curried pprint* pprint-object ;
M: composed pprint* pprint-object ;
M: hash-set pprint* pprint-object ;
M: anonymous-union pprint* pprint-object ;
M: anonymous-intersection pprint* pprint-object ;
M: anonymous-complement pprint* pprint-object ;
M: anonymous-predicate pprint* pprint-object ;
M: maybe pprint* pprint-object ;

M: wrapper pprint*
    {
        { [ dup wrapped>> method? ] [ wrapped>> pprint* ] }
        { [ dup wrapped>> word? ] [ <block \ \ pprint-word wrapped>> pprint-word block> ] }
        [ pprint-object ]
    } cond ;
