! Copyright (C) 2003, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: prettyprint
USING: alien arrays generic generic.standard assocs io kernel
math namespaces sequences strings io.styles io.streams.string
vectors words prettyprint.backend prettyprint.sections
prettyprint.config sorting splitting math.parser vocabs
definitions effects tuples io.files classes continuations
hashtables classes.mixin classes.union classes.predicate
combinators quotations ;

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
    dup empty? [ drop ] [
        natural-sort [
            \ USING: pprint-word
            [ pprint-vocab ] each
            \ ; pprint-word
        ] with-pprint nl
    ] if ;

: vocabs. ( in use -- )
    dupd remove [ { "syntax" "scratchpad" } member? not ] subset
    use. in. ;

: with-use ( obj quot -- )
    make-pprint vocabs. do-pprint ; inline

: with-in ( obj quot -- )
    make-pprint drop [ write-in bl ] when* do-pprint ; inline

: pprint ( obj -- ) [ pprint* ] with-pprint ;

: . ( obj -- )
    H{
       { length-limit 1000 }
       { nesting-limit 10 }
    } clone [ pprint ] bind nl ;

: pprint-use ( obj -- ) [ pprint* ] with-use ;

: unparse ( obj -- str ) [ pprint ] string-out ;

: unparse-use ( obj -- str ) [ pprint-use ] string-out ;

: pprint-short ( obj -- )
    H{
       { line-limit 1 }
       { length-limit 15 }
       { nesting-limit 2 }
       { string-limit t }
    } clone [ pprint ] bind ;

: short. ( obj -- ) pprint-short nl ;

: .b ( n -- ) >bin print ;
: .o ( n -- ) >oct print ;
: .h ( n -- ) >hex print ;

: stack. ( seq -- ) [ short. ] each ;

: .s ( -- ) datastack stack. ;
: .r ( -- ) retainstack stack. ;

SYMBOL: ->

\ ->
{ { foreground { 1 1 1 1 } } { background { 0 0 0 1 } } }
"word-style" set-word-prop

<PRIVATE

! This code is ugly and could probably be simplified
: remove-step-into
    building get dup empty? [
        drop \ (step-into) ,
    ] [
        pop dup wrapper? [
            wrapped dup \ break eq?
            [ drop ] [ , ] if
        ] [
            ,
        ] if
    ] if ;

: (remove-breakpoints) ( quot -- newquot )
    [
        [
            {
                { break [ ] }
                { (step-into) [ remove-step-into ] }
                [ , ]
            } case
        ] each
    ] [ ] make ;

: remove-breakpoints ( quot pos -- quot' )
    over quotation? [
        1+ swap cut [ (remove-breakpoints) ] 2apply
        [ -> ] swap 3append
    ] [
        drop
    ] if ;

PRIVATE>

: callstack. ( callstack -- )
    callstack>array 2 <groups> [
        remove-breakpoints
        2 nesting-limit [ . ] with-variable
    ] assoc-each ;

: .c ( -- ) callstack callstack. ;

: pprint-cell ( obj -- ) [ pprint ] with-cell ;

GENERIC: see ( defspec -- )

: comment. ( string -- )
    [ H{ { font-style italic } } styled-text ] when* ;

: seeing-word ( word -- )
    word-vocabulary pprinter-in set ;

: stack-effect. ( word -- )
    dup parsing? over symbol? or not swap stack-effect and
    [ effect>string comment. ] when* ;

: word-synopsis ( word name -- )
    dup seeing-word
    over definer drop pprint-word
    pprint-word
    stack-effect. ;

M: word synopsis*
    dup word-synopsis ;

M: standard-generic synopsis*
    dup seeing-word
    \ GENERIC# pprint-word
    dup pprint-word
    dup dispatch# pprint*
    stack-effect. ;

M: hook-generic synopsis*
    dup seeing-word
    \ HOOK: pprint-word
    dup pprint-word
    dup "combination" word-prop hook-combination-var pprint-word
    stack-effect. ;

M: method-spec synopsis*
    dup definer drop pprint-word
    [ pprint-word ] each ;

M: pathname synopsis* pprint* ;

: synopsis ( defspec -- str )
    [
        0 margin set
        1 line-limit set
        [ synopsis* ] with-in
    ] string-out ;

GENERIC: declarations. ( obj -- )

M: object declarations. drop ;

: declaration. ( word prop -- )
    tuck word-name word-prop [ pprint-word ] [ drop ] if ;

M: word declarations.
    {
        POSTPONE: parsing
        POSTPONE: delimiter
        POSTPONE: inline
        POSTPONE: foldable
    } [ declaration. ] curry* each ;

: pprint-; \ ; pprint-word ;

: (see) ( spec -- )
    [
        <colon dup synopsis*
        <block dup definition pprint-elements block>
        dup definer nip [ pprint-word ] when* declarations.
        block>
    ] with-use nl ;

M: object see (see) ;

GENERIC: see-class* ( word -- )

M: union-class see-class*
    \ UNION: pprint-word
    dup pprint-word
    members pprint-elements pprint-; ;

M: mixin-class see-class*
    \ MIXIN: pprint-word
    dup pprint-word <block
    dup members [
        hard break
        \ INSTANCE: pprint-word pprint-word pprint-word
    ] curry* each block> ;

M: predicate-class see-class*
    <colon \ PREDICATE: pprint-word
    dup superclass pprint-word
    dup pprint-word
    <block
    "predicate-definition" word-prop pprint-elements
    pprint-; block> block> ;

M: tuple-class see-class*
    \ TUPLE: pprint-word
    dup pprint-word
    "slot-names" word-prop [ text ] each
    pprint-; ;

M: word see-class* drop ;

M: builtin-class see-class*
    drop "! Built-in class" comment. ;

: see-all ( seq -- ) natural-sort [ nl see ] each ;

: see-implementors ( class -- seq )
    dup implementors [ 2array ] curry* map ;

: see-class ( class -- )
    dup class? [
        nl [ dup see-class* ] with-pprint nl
    ] when drop ;

: see-methods ( generic -- seq )
    [ "methods" word-prop keys natural-sort ] keep
    [ 2array ] curry map ;

M: word see
    dup (see)
    dup see-class
    [
        dup class? [ dup see-implementors % ] when
        dup generic? [ dup see-methods % ] when
        drop
    ] { } make prune see-all ;
