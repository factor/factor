! Copyright (C) 2003, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays generic generic.standard assocs io kernel math
namespaces make sequences strings io.styles io.streams.string
vectors words words.symbol prettyprint.backend prettyprint.custom
prettyprint.sections prettyprint.config sorting splitting
grouping math.parser vocabs definitions effects classes.builtin
classes.tuple io.pathnames classes continuations hashtables
classes.mixin classes.union classes.intersection
classes.predicate classes.singleton combinators quotations sets
accessors colors parser summary vocabs.parser ;
IN: prettyprint

: make-pprint ( obj quot -- block in use )
    [
        0 position set
        H{ } clone pprinter-use set
        V{ } clone recursion-check set
        V{ } clone pprinter-stack set
        over <object
        call
        pprinter-block
        pprinter-in get
        pprinter-use get keys
    ] with-scope ; inline

: with-pprint ( obj quot -- )
    make-pprint 2drop do-pprint ; inline

: pprint-vocab ( vocab -- )
    dup vocab present-text ;

: write-in ( vocab -- )
    [ \ IN: pprint-word pprint-vocab ] with-pprint ;

: in. ( vocab -- )
    [ write-in nl ] when* ;

: use. ( seq -- )
    [
        natural-sort [
            \ USING: pprint-word
            [ pprint-vocab ] each
            \ ; pprint-word
        ] with-pprint nl
    ] unless-empty ;

: use/in. ( in use -- )
    dupd remove [ { "syntax" "scratchpad" } member? not ] filter
    use. in. ;

: vocab-names ( words -- vocabs )
    dictionary get
    [ [ words>> eq? nip ] with assoc-find 2drop ] curry map sift ;

: prelude. ( -- )
    in get use get vocab-names use/in. ;

[
    nl
    "Restarts were invoked adding vocabularies to the search path." print
    "To avoid doing this in the future, add the following USING:" print
    "and IN: forms at the top of the source file:" print nl
    prelude.
    nl
] print-use-hook set-global

: with-use ( obj quot -- )
    make-pprint use/in. do-pprint ; inline

: with-in ( obj quot -- )
    make-pprint drop [ write-in bl ] when* do-pprint ; inline

: pprint ( obj -- ) [ pprint* ] with-pprint ;

: . ( obj -- ) pprint nl ;

: pprint-use ( obj -- ) [ pprint* ] with-use ;

: unparse ( obj -- str ) [ pprint ] with-string-writer ;

: unparse-use ( obj -- str ) [ pprint-use ] with-string-writer ;

: pprint-short ( obj -- )
    H{
       { line-limit 1 }
       { length-limit 15 }
       { nesting-limit 2 }
       { string-limit? t }
       { boa-tuples? t }
    } clone [ pprint ] bind ;

: unparse-short ( obj -- str )
    [ pprint-short ] with-string-writer ;

: short. ( obj -- ) pprint-short nl ;

: .b ( n -- ) >bin print ;
: .o ( n -- ) >oct print ;
: .h ( n -- ) >hex print ;

: stack. ( seq -- ) [ short. ] each ;

: .s ( -- ) datastack stack. ;
: .r ( -- ) retainstack stack. ;

<PRIVATE

SYMBOL: ->

\ ->
{ { foreground T{ rgba f 1 1 1 1 } } { background T{ rgba f 0 0 0 1 } } }
"word-style" set-word-prop

: remove-step-into ( word -- )
    building get [ nip pop wrapped>> ] unless-empty , ;

: (remove-breakpoints) ( quot -- newquot )
    [
        [
            {
                { [ dup word? not ] [ , ] }
                { [ dup "break?" word-prop ] [ drop ] }
                { [ dup "step-into?" word-prop ] [ remove-step-into ] }
                [ , ]
            } cond
        ] each
    ] [ ] make ;

: remove-breakpoints ( quot pos -- quot' )
    over quotation? [
        1+ cut [ (remove-breakpoints) ] bi@
        [ -> ] glue 
    ] [
        drop
    ] if ;

PRIVATE>

: callstack. ( callstack -- )
    callstack>array 2 <groups> [
        remove-breakpoints
        [
            3 nesting-limit set
            100 length-limit set
            .
        ] with-scope
    ] assoc-each ;

: .c ( -- ) callstack callstack. ;

: pprint-cell ( obj -- ) [ pprint-short ] with-cell ;

SYMBOL: pprint-string-cells?

: simple-table. ( values -- )
    standard-table-style [
        [
            [
                [
                    dup string? pprint-string-cells? get not and
                    [ [ write ] with-cell ]
                    [ pprint-cell ]
                    if
                ] each
            ] with-row
        ] each
    ] tabular-output nl ;

GENERIC: see ( defspec -- )

: comment. ( string -- )
    [ H{ { font-style italic } } styled-text ] when* ;

: seeing-word ( word -- )
    vocabulary>> pprinter-in set ;

: definer. ( defspec -- )
    definer drop pprint-word ;

: stack-effect. ( word -- )
    [ [ parsing-word? ] [ symbol? ] bi or not ] [ stack-effect ] bi and
    [ effect>string comment. ] when* ;

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

M: method-spec synopsis*
    first2 method synopsis* ;

M: method-body synopsis*
    [ definer. ]
    [ "method-class" word-prop pprint-word ]
    [ "method-generic" word-prop pprint-word ] tri ;

M: mixin-instance synopsis*
    [ definer. ]
    [ class>> pprint-word ]
    [ mixin>> pprint-word ] tri ;

M: pathname synopsis* pprint* ;

: synopsis ( defspec -- str )
    [
        0 margin set
        1 line-limit set
        [ synopsis* ] with-in
    ] with-string-writer ;

M: word summary synopsis ;

GENERIC: declarations. ( obj -- )

M: object declarations. drop ;

: declaration. ( word prop -- )
    [ nip ] [ name>> word-prop ] 2bi
    [ pprint-word ] [ drop ] if ;

M: word declarations.
    {
        POSTPONE: parsing
        POSTPONE: delimiter
        POSTPONE: inline
        POSTPONE: recursive
        POSTPONE: foldable
        POSTPONE: flushable
    } [ declaration. ] with each ;

: pprint-; ( -- ) \ ; pprint-word ;

M: object see
    [
        12 nesting-limit set
        100 length-limit set
        <colon dup synopsis*
        <block dup definition pprint-elements block>
        dup definer nip [ pprint-word ] when* declarations.
        block>
    ] with-use nl ;

M: method-spec see
    first2 method see ;

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
            dup seeing-word dup see-class*
        ] with-use nl
    ] when drop ;

M: word see
    [ see-class ]
    [ [ class? ] [ symbol? not ] bi and [ nl ] when ]
    [
        dup [ class? ] [ symbol? ] bi and
        [ drop ] [ call-next-method ] if
    ] tri ;

: see-all ( seq -- )
    natural-sort [ nl ] [ see ] interleave ;

: (see-implementors) ( class -- seq )
    dup implementors [ method ] with map natural-sort ;

: (see-methods) ( generic -- seq )
    "methods" word-prop values natural-sort ;

: methods ( word -- seq )
    [
        dup class? [ dup (see-implementors) % ] when
        dup generic? [ dup (see-methods) % ] when
        drop
    ] { } make prune ;

: see-methods ( word -- )
    methods see-all ;
