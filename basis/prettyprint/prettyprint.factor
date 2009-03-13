! Copyright (C) 2003, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays accessors assocs colors combinators grouping io
io.streams.string io.styles kernel make math math.parser namespaces
parser prettyprint.backend prettyprint.config prettyprint.custom
prettyprint.sections quotations sequences sorting strings vocabs
vocabs.parser words sets ;
IN: prettyprint

<PRIVATE

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
    [ write-in ] when* ;

: use. ( seq -- )
    [
        natural-sort [
            \ USING: pprint-word
            [ pprint-vocab ] each
            \ ; pprint-word
        ] with-pprint
    ] unless-empty ;

: use/in. ( in use -- )
    over "syntax" 2array diff
    [ nip use. ]
    [ empty? not and [ nl ] when ]
    [ drop in. ]
    2tri ;

: vocab-names ( words -- vocabs )
    dictionary get
    [ [ words>> eq? nip ] with assoc-find 2drop ] curry map sift ;

: prelude. ( -- )
    in get use get vocab-names prune in get ".private" append swap remove use/in. ;

[
    nl
    { { font-style bold } { font-name "sans-serif" } } [
        "Restarts were invoked adding vocabularies to the search path." print
        "To avoid doing this in the future, add the following USING:" print
        "and IN: forms at the top of the source file:" print nl
    ] with-style
    { { page-color T{ rgba f 0.8 0.8 0.8 1.0 } } } [ prelude. ] with-nesting
    nl nl
] print-use-hook set-global

PRIVATE>

: with-use ( obj quot -- )
    make-pprint [ use/in. ] [ empty? not or [ nl ] when ] 2bi
    do-pprint ; inline

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