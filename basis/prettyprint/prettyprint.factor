! Copyright (C) 2003, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays colors combinators grouping io
io.streams.string io.styles kernel make math namespaces
prettyprint.config prettyprint.custom prettyprint.sections
sequences strings vocabs.prettyprint words ;
IN: prettyprint

: with-use ( obj quot -- )
    t make-pprint (pprint-manifest
    [ pprint-manifest) ] [ [ drop nl ] unless-empty ] bi
    do-pprint ; inline

: with-in ( obj quot -- )
    t make-pprint current-vocab>> [ pprint-in bl ] when* do-pprint ; inline

: pprint ( obj -- ) [ pprint* ] with-pprint ;

: . ( obj -- ) pprint nl ;

: ... ( obj -- ) [ . ] without-limits ;

: pprint-use ( obj -- ) [ pprint* ] with-use ;

: unparse ( obj -- str ) [ pprint ] with-string-writer ;

: unparse-use ( obj -- str ) [ pprint-use ] with-string-writer ;

: pprint-short ( obj -- )
    [ pprint ] with-short-limits ;

: unparse-short ( obj -- str )
    [ pprint-short ] with-string-writer ;

: short. ( obj -- ) pprint-short nl ;

: .b ( n -- ) 2 number-base [ . ] with-variable ;
: .o ( n -- ) 8 number-base [ . ] with-variable ;
: .h ( n -- ) 16 number-base [ . ] with-variable ;

: stack. ( seq -- ) [ short. ] each ;

: datastack. ( seq -- )
    [ nl "--- Data stack:" print stack. ] unless-empty ;

: .s ( -- ) get-datastack stack. ;
: .r ( -- ) get-retainstack stack. ;

<PRIVATE

SYMBOL: =>

\ =>
{ { foreground COLOR: white } { background COLOR: black } }
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
    1 + index-or-length cut [ (remove-breakpoints) ] bi@ [ => ] glue ;

: optimized-frame? ( triple -- ? ) second word? ;

: frame-word? ( triple -- ? )
    first word? ;

: frame-word. ( triple -- )
    first pprint ;

: optimized-frame. ( triple -- )
    [
        [ "(O)" write ] with-cell
        [ frame-word. ] with-cell
    ] with-row ;

: unoptimized-frame. ( triple -- )
    [
        [ "(U)" write ] with-cell
        [
            dup [ second ] [ third ] bi remove-breakpoints
            H{
                { nesting-limit 3 }
                { length-limit 100 }
            } clone [ pprint ] with-variables
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
    callstack>array 3 <groups> reverse
    { { table-gap { 5 5 } } } [ [ callframe. ] each ] tabular-output nl ;

: .c ( -- ) get-callstack callstack. ;

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
