! Copyright (C) 2009, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs classes classes.builtin
classes.error classes.intersection classes.mixin
classes.predicate classes.singleton classes.tuple classes.union
combinators definitions effects generic generic.hook
generic.single generic.standard io io.pathnames
io.streams.string io.styles kernel make namespaces prettyprint
prettyprint.backend prettyprint.config prettyprint.custom
prettyprint.sections sequences sets slots sorting strings
summary vocabs vocabs.prettyprint words words.alias
words.constant words.symbol ;
IN: see

GENERIC: synopsis* ( defspec -- )

GENERIC: see* ( defspec -- )

: see ( defspec -- ) see* nl ;

: synopsis ( defspec -- str )
    H{
        { string-limit? f }
        { margin 0 }
        { line-limit 1 }
    } clone [
        [ [ synopsis* ] with-in ] with-string-writer
    ] with-variables ;

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
    [ pprint-effect ] when* ;

<PRIVATE

: seeing-word ( word -- )
    vocabulary>> dup [ lookup-vocab ] when pprinter-in namespaces:set ;

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

M: method synopsis*
    [ definer. ]
    [ "method-class" word-prop pprint-class ]
    [ "method-generic" word-prop pprint-word ] tri ;

M: mixin-instance synopsis*
    [ definer. ]
    [ class>> pprint-word ]
    [ mixin>> pprint-word ] tri ;

M: pathname synopsis* pprint* ;

M: alias summary
    [
        0 margin namespaces:set
        1 line-limit namespaces:set
        [
            {
                [ seeing-word ]
                [ definer. ]
                [ pprint-word ]
                [ stack-effect pprint-effect ]
            } cleave
        ] with-in
    ] with-string-writer ;

M: word summary synopsis ;

GENERIC: declarations. ( obj -- )

M: object declarations. drop ;

: declaration. ( word prop -- )
    [ nip ] [ name>> word-prop ] 2bi
    [ pprint-word ] [ drop ] if ;

M: word declarations.
    {
        POSTPONE: delimiter
        POSTPONE: deprecated
        POSTPONE: inline
        POSTPONE: recursive
        POSTPONE: foldable
        POSTPONE: flushable
    } [ declaration. ] with each ;

M: object see*
    [
        12 nesting-limit namespaces:set
        100 length-limit namespaces:set
        <colon dup synopsis*
        <block dup definition pprint-elements block>
        dup definer nip [ pprint-word ] when* declarations.
        block>
    ] with-use ;

GENERIC: see-class* ( word -- )

M: union-class see-class*
    <colon \ UNION: pprint-word
    dup pprint-word
    class-members pprint-elements pprint-; block> ;

M: intersection-class see-class*
    <colon \ INTERSECTION: pprint-word
    dup pprint-word
    class-participants pprint-elements pprint-; block> ;

M: mixin-class see-class*
    <block \ MIXIN: pprint-word
    dup pprint-word <block
    dup class-members [
        hard add-line-break
        \ INSTANCE: pprint-word pprint-word pprint-word
    ] with each block> block> ;

M: predicate-class see-class*
    <colon \ PREDICATE: pprint-word
    dup pprint-word
    "<" text
    dup superclass-of pprint-word
    <block
    "predicate-definition" word-prop pprint-elements
    pprint-; block> block> ;

M: singleton-class see-class*
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
        ] unless
        dup read-only>> [
            read-only ,
        ] when
        dup [ class>> object eq? not ] [ initial>> ] bi or [
            initial: ,
            dup initial>> ,
        ] when
        drop
    ] { } make ;

: pprint-slot ( slot-spec -- )
    unparse-slot
    dup length 1 = [ first ] when
    pprint-slot-name ;

: tuple-declarations. ( class -- )
    \ final declaration. ;

: superclass. ( class -- )
    superclass-of dup tuple eq? [ drop ] [ "<" text pprint-word ] if ;

M: tuple-class see-class*
    <colon \ TUPLE: pprint-word
    {
        [ pprint-word ]
        [ superclass. ]
        [ <block "slots" word-prop [ pprint-slot ] each block> pprint-; ]
        [ tuple-declarations. ]
    } cleave
    block> ;

M: word see-class* drop ;

M: builtin-class see-class*
    <block
    \ BUILTIN: pprint-word
    [ pprint-word ]
    [ <block "slots" word-prop [ pprint-slot ] each pprint-; block> ] bi
    block> ;

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

M: error-class see-class*
    <colon \ ERROR: pprint-word
    {
        [ pprint-word ]
        [ superclass. ]
        [ <block "slots" word-prop [ name>> pprint-slot-name ] each block> pprint-; ]
        [ tuple-declarations. ]
    } cleave
    block> ;

M: error-class see* see-class ;

: seeing-implementors ( class -- seq )
    dup implementors
    [ [ reader? ] [ writer? ] bi or ] reject
    [ lookup-method ] with map
    sort ;

: seeing-methods ( generic -- seq )
    "methods" word-prop values sort ;

PRIVATE>

: see-all ( seq -- )
    sort [ nl nl ] [ see* ] interleave ;

: methods ( word -- seq )
    [
        dup class? [ dup seeing-implementors % ] when
        dup generic? [ dup seeing-methods % ] when
        drop
    ] { } make members ;

: see-methods ( word -- )
    methods see-all nl ;
