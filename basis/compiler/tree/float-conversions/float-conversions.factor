! Copyright (C) 2026 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators compiler.tree
compiler.tree.combinators compiler.tree.def-use
compiler.tree.def-use.simplified kernel locals math math.private
sequences sets stack-checker.dependencies words ;
IN: compiler.tree.float-conversions

: literal-float-conversion? ( node -- ? )
    dup #call? [ word>> \ fixnum>float eq? ] [ drop f ] if ;

:: forwarded-values ( value node -- values/f )
    {
        { [ node #shuffle? node #copy? or ] [
            node inputs/outputs [ value swap indices ] dip nths
        ] }
        { [ node #phi? ] [
            node out-d>> length <iota> [| i |
                node phi-in-d>> [ i swap nth value = ] any?
            ] filter node out-d>> nths
        ] }
        [ f ]
    } cond ;

:: conversion-only-use? ( value call visited -- ? )
    value visited ?adjoin [
        value used-by [| node |
            node call eq? [ t ] [
                value node forwarded-values [
                    [ call visited conversion-only-use? ] all?
                ] [ f ] if*
            ] if
        ] all?
    ] [ t ] if ;

:: convertible-literal? ( usage call -- ? )
    usage node>> :> node
    node #push? [
        node literal>> dup fixnum? [
            ! Exact conversions preserve every rounding mode and FP flag.
            abs 0x20000000000000 <=
        ] [ drop f ] if
        [ usage value>> call HS{ } clone conversion-only-use? ] [ f ] if
    ] [ f ] if ;

:: fold-literal-float-conversion ( call -- node )
    call in-d>> first actually-defined-by :> definitions
    definitions empty? not
    [ definitions [ call convertible-literal? ] all? ] [ f ] if [
        definitions [ node>> [ fixnum>float ] change-literal drop ] each
        call word>> +definition+ depends-on
        call [ in-d>> ] [ out-d>> ] bi
        2dup swap zip <#data-shuffle>
    ] [ call ] if ;

: fold-literal-float-conversions ( nodes -- nodes' )
    dup [ literal-float-conversion? ] contains-node? [
        compute-def-use [
            dup literal-float-conversion? [ fold-literal-float-conversion ] when
        ] map-nodes
    ] when ;
