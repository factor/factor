! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs classes classes.builtin
classes.intersection classes.mixin classes.predicate classes.singleton
classes.tuple classes.union combinators definitions effects generic
generic.single generic.standard generic.hook io io.pathnames
io.streams.string io.styles kernel make namespaces prettyprint
prettyprint.backend prettyprint.config prettyprint.custom
prettyprint.sections sequences sets sorting strings summary words
words.symbol words.constant words.alias ;
IN: see

GENERIC: synopsis* ( defspec -- )

GENERIC: see* ( defspec -- )

: see ( defspec -- ) see* nl ;

: synopsis ( defspec -- str )
    [
        0 margin set
        1 line-limit set
        [ synopsis* ] with-in
    ] with-string-writer ;

: definer. ( defspec -- )
    definer drop pprint-word ;

: comment. ( text -- )
    H{ { font-style italic } } styled-text ;

GENERIC: print-stack-effect? ( word -- ? )

M: parsing-word print-stack-effect? drop f ;
M: symbol print-stack-effect? drop f ;
M: constant print-stack-effect? drop f ;
M: alias print-stack-effect? drop f ;
M: word print-stack-effect? drop t ;

: stack-effect. ( word -- )
    [ print-stack-effect? ] [ stack-effect ] bi and
    [ effect>string comment. ] when* ;

<PRIVATE

: seeing-word ( word -- )
    vocabulary>> pprinter-in set ;

: word-synopsis ( word -- )
    {
        [ seeing-word ]
        [ definer. ]
        [ pprint-word ]
        [ stack-effect. ] 
    } cleave ;

M: word synopsis* word-synopsis ;

M: simple-generic synopsis* word-synopsis ;

M: standard-generic synopsis*
    {
        [ definer. ]
        [ seeing-word ]
        [ pprint-word ]
        [ dispatch# pprint* ]
        [ stack-effect. ]
    } cleave ;

M: hook-generic synopsis*
    {
        [ definer. ]
        [ seeing-word ]
        [ pprint-word ]
        [ "combination" word-prop var>> pprint* ]
        [ stack-effect. ]
    } cleave ;

M: method-body synopsis*
    [ definer. ]
    [ "method-class" word-prop pprint-word ]
    [ "method-generic" word-prop pprint-word ] tri ;

M: mixin-instance synopsis*
    [ definer. ]
    [ class>> pprint-word ]
    [ mixin>> pprint-word ] tri ;

M: pathname synopsis* pprint* ;

M: word summary synopsis ;

GENERIC: declarations. ( obj -- )

M: object declarations. drop ;

: declaration. ( word prop -- )
    [ nip ] [ name>> word-prop ] 2bi
    [ pprint-word ] [ drop ] if ;

M: word declarations.
    {
        POSTPONE: delimiter
        POSTPONE: inline
        POSTPONE: recursive
        POSTPONE: foldable
        POSTPONE: flushable
    } [ declaration. ] with each ;

: pprint-; ( -- ) \ ; pprint-word ;

M: object see*
    [
        12 nesting-limit set
        100 length-limit set
        <colon dup synopsis*
        <block dup definition pprint-elements block>
        dup definer nip [ pprint-word ] when* declarations.
        block>
    ] with-use ;

GENERIC: see-class* ( word -- )

M: union-class see-class*
    <colon \ UNION: pprint-word
    dup pprint-word
    members pprint-elements pprint-; block> ;

M: intersection-class see-class*
    <colon \ INTERSECTION: pprint-word
    dup pprint-word
    participants pprint-elements pprint-; block> ;

M: mixin-class see-class*
    <block \ MIXIN: pprint-word
    dup pprint-word <block
    dup members [
        hard line-break
        \ INSTANCE: pprint-word pprint-word pprint-word
    ] with each block> block> ;

M: predicate-class see-class*
    <colon \ PREDICATE: pprint-word
    dup pprint-word
    "<" text
    dup superclass pprint-word
    <block
    "predicate-definition" word-prop pprint-elements
    pprint-; block> block> ;

M: singleton-class see-class* ( class -- )
    \ SINGLETON: pprint-word pprint-word ;

GENERIC: pprint-slot-name ( object -- )

M: string pprint-slot-name text ;

M: array pprint-slot-name
    <flow \ { pprint-word
    f <inset unclip text pprint-elements block>
    \ } pprint-word block> ;

: unparse-slot ( slot-spec -- array )
    [
        dup name>> ,
        dup class>> object eq? [
            dup class>> ,
            initial: ,
            dup initial>> ,
        ] unless
        dup read-only>> [
            read-only ,
        ] when
        drop
    ] { } make ;

: pprint-slot ( slot-spec -- )
    unparse-slot
    dup length 1 = [ first ] when
    pprint-slot-name ;

M: tuple-class see-class*
    <colon \ TUPLE: pprint-word
    dup pprint-word
    dup superclass tuple eq? [
        "<" text dup superclass pprint-word
    ] unless
    <block "slots" word-prop [ pprint-slot ] each block>
    pprint-; block> ;

M: word see-class* drop ;

M: builtin-class see-class*
    drop "! Built-in class" comment. ;

: see-class ( class -- )
    dup class? [
        [
            [ seeing-word ] [ see-class* ] bi
        ] with-use
    ] [ drop ] if ;

M: word see*
    [ see-class ]
    [ [ class? ] [ symbol? not ] bi and [ nl nl ] when ]
    [
        dup [ class? ] [ symbol? ] bi and
        [ drop ] [ call-next-method ] if
    ] tri ;

: seeing-implementors ( class -- seq )
    dup implementors [ method ] with map natural-sort ;

: seeing-methods ( generic -- seq )
    "methods" word-prop values natural-sort ;

PRIVATE>

: see-all ( seq -- )
    natural-sort [ nl nl ] [ see* ] interleave ;

: methods ( word -- seq )
    [
        dup class? [ dup seeing-implementors % ] when
        dup generic? [ dup seeing-methods % ] when
        drop
    ] { } make prune ;

: see-methods ( word -- )
    methods see-all nl ;