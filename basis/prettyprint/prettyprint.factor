! Copyright (C) 2003, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays accessors assocs colors combinators grouping io
io.streams.string io.styles kernel make math math.parser namespaces
parser prettyprint.backend prettyprint.config prettyprint.custom
prettyprint.sections quotations sequences sorting strings vocabs
vocabs.prettyprint words sets ;
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
        1 + cut [ (remove-breakpoints) ] bi@
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

: object-table. ( obj alist -- )
    [ [ nip first ] [ second call( obj -- str ) ] 2bi 2array ] with map
    simple-table. ;
