! Copyright (C) 2003, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays accessors assocs colors combinators grouping io
io.streams.string io.styles kernel make math math.parser namespaces
parser prettyprint.backend prettyprint.config prettyprint.custom
prettyprint.sections quotations sequences sorting strings vocabs
vocabs.prettyprint words sets generic ;
FROM: namespaces => set ;
IN: prettyprint

: with-use ( obj quot -- )
    make-pprint (pprint-manifest
    [ pprint-manifest) ] [ [ drop nl ] unless-empty ] bi
    do-pprint ; inline

: with-in ( obj quot -- )
    make-pprint current-vocab>> [ pprint-in bl ] when* do-pprint ; inline

: pprint ( obj -- ) [ pprint* ] with-pprint ;

: . ( obj -- ) pprint nl ;

: pprint-use ( obj -- ) [ pprint* ] with-use ;

: unparse ( obj -- str ) [ pprint ] with-string-writer ;

: unparse-use ( obj -- str ) [ pprint-use ] with-string-writer ;

: pprint-short ( obj -- )
    [ pprint ] with-short-limits ;

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
    1 + short cut [ (remove-breakpoints) ] bi@ [ -> ] glue ;

: optimized-frame? ( triple -- ? ) second word? ;

: frame-word? ( triple -- ? )
    first word? ;

: frame-word. ( triple -- )
    first {
        { [ dup method? ] [ "Method: " write pprint ] }
        { [ dup word? ] [ "Word: " write pprint ] }
        [ drop ]
    } cond ;

: optimized-frame. ( triple -- )
    [
        [ "(O)" write ] with-cell
        [ frame-word. ] with-cell
    ] with-row ;

: unoptimized-frame. ( triple -- )
    [
        [ "(U)" write ] with-cell
        [
            "Quotation: " write
            dup [ second ] [ third ] bi remove-breakpoints
            [
                3 nesting-limit set
                100 length-limit set
                pprint
            ] with-scope
        ] with-cell
    ] with-row
    dup frame-word? [
        [
            [ ] with-cell
            [ frame-word. ] with-cell
        ] with-row
    ] [ drop ] if ;

: callframe. ( triple -- )
    dup optimized-frame?
    [ optimized-frame. ] [ unoptimized-frame. ] if ;

PRIVATE>

: callstack. ( callstack -- )
    callstack>array 3 <groups>
    { { table-gap { 5 5 } } } [ [ callframe. ] each ] tabular-output nl ;

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

: object-table. ( obj alist -- )
    [ [ nip first ] [ second call( obj -- str ) ] 2bi 2array ] with map
    simple-table. ;
