! Copyright (C) 2008, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs classes.tuple.private combinators
compiler.tree compiler.tree.builder compiler.tree.combinators
compiler.tree.escape-analysis.allocations
compiler.tree.escape-analysis.simple compiler.tree.propagation
compiler.utilities fry kernel kernel.private math namespaces
sequences slots.private stack-checker.branches
stack-checker.values vectors ;
IN: compiler.tree.tuple-unboxing

GENERIC: unbox-tuples* ( node -- node/nodes )

: unbox-output? ( node -- values )
    out-d>> first unboxed-allocation ;

: (expand-#push) ( object value -- nodes )
    dup unboxed-allocation dup [
        [ object-slots ] [ drop ] [ ] tri*
        [ (expand-#push) ] 2map-flat
    ] [
        drop <#push>
    ] if ;

: expand-#push ( #push -- nodes )
    [ literal>> ] [ out-d>> first ] bi (expand-#push) ;

M: #push unbox-tuples* ( #push -- nodes )
    dup unbox-output? [ expand-#push ] when ;

: unbox-<tuple-boa> ( #call -- nodes )
    dup unbox-output? [ in-d>> 1 tail* <#drop> ] when ;

: (flatten-values) ( values accum -- )
    dup '[
        [ unboxed-allocation ]
        [ _ (flatten-values) ] [ _ push ] ?if
    ] each ;

: flatten-values ( values -- values' )
    dup empty? [
        10 <vector> [ (flatten-values) ] keep
    ] unless ;

: prepare-slot-access ( #call -- tuple-values outputs slot-values )
    [ in-d>> flatten-values ]
    [ out-d>> flatten-values ]
    [
        out-d>> first slot-accesses get at
        [ slot#>> ] [ value>> ] bi allocation nth
        1array flatten-values
    ] tri ;

: slot-access-shuffle ( tuple-values outputs slot-values -- #shuffle )
    [ drop ] [ zip ] 2bi <#data-shuffle> ;

: unbox-slot-access ( #call -- nodes )
    dup out-d>> first unboxed-slot-access? [
        prepare-slot-access slot-access-shuffle
    ] when ;

M: #call unbox-tuples*
    dup word>> {
        { \ <tuple-boa> [ unbox-<tuple-boa> ] }
        { \ slot [ unbox-slot-access ] }
        [ drop ]
    } case ;

M: #declare unbox-tuples*
    ! We don't look at declarations after escape analysis anyway.
    drop f ;

M: #copy unbox-tuples*
    [ flatten-values ] change-in-d
    [ flatten-values ] change-out-d ;

M: #shuffle unbox-tuples*
    [ flatten-values ] change-in-d
    [ flatten-values ] change-out-d
    [ flatten-values ] change-in-r
    [ flatten-values ] change-out-r
    [ unzip [ flatten-values ] bi@ zip ] change-mapping ;

M: #terminate unbox-tuples*
    [ flatten-values ] change-in-d
    [ flatten-values ] change-in-r ;

M: #phi unbox-tuples*
    ! pad-with-bottom is only needed if some branches are terminated,
    ! which means all output values are bottom
    [ [ flatten-values ] map pad-with-bottom ] change-phi-in-d
    [ flatten-values ] change-out-d ;

M: #recursive unbox-tuples*
    [ label>> [ flatten-values ] change-enter-out drop ]
    [ [ flatten-values ] change-in-d ]
    bi ;

M: #enter-recursive unbox-tuples*
    [ flatten-values ] change-in-d
    [ flatten-values ] change-out-d ;

M: #call-recursive unbox-tuples*
    [ flatten-values ] change-in-d
    [ flatten-values ] change-out-d ;

M: #return-recursive unbox-tuples*
    [ flatten-values ] change-in-d
    [ flatten-values ] change-out-d ;

: value-declaration ( value -- quot )
    value-class [ 1array '[ _ declare ] ] [ [ ] ] if* ;

: unbox-parameter-quot ( allocation -- quot )
    dup unboxed-allocation {
        { [ dup not ] [ 2drop [ ] ] }
        { [ dup array? ] [
            [ value-declaration ] [
                [
                    [ unbox-parameter-quot ] [ 2 + '[ _ slot ] ] bi*
                    prepose
                ] map-index
            ] bi* '[ @ _ cleave ]
        ] }
    } cond ;

: unbox-parameters-quot ( values -- quot )
    [ unbox-parameter-quot ] map
    dup [ [ ] = ] all? [ drop [ ] ] [ '[ _ spread ] ] if ;

: unbox-parameters-nodes ( new-values old-values -- nodes )
    [ flatten-values ] [ unbox-parameters-quot ] bi build-sub-tree ;

: new-and-old-values ( values -- new-values old-values )
    [ length [ <value> ] replicate ] keep ;

: unbox-hairy-introduce ( #introduce -- nodes )
    dup out-d>> new-and-old-values
    [ drop >>out-d ] [ unbox-parameters-nodes ] 2bi
    swap prefix propagate ;

M: #introduce unbox-tuples*
    ! For every output that is unboxed, insert slot accessors
    ! to convert the stack value into its unboxed form
    dup out-d>> [ unboxed-allocation ] any? [
        unbox-hairy-introduce
    ] when ;

! These nodes never participate in unboxing
: assert-not-unboxed ( values -- )
    dup array?
    [ [ unboxed-allocation ] any? ] [ unboxed-allocation ] if
    [ "Unboxing wrong value" throw ] when ;

M: #branch unbox-tuples* dup in-d>> assert-not-unboxed ;

M: #return unbox-tuples* dup in-d>> assert-not-unboxed ;

M: #alien-node unbox-tuples* dup in-d>> assert-not-unboxed ;

M: #alien-callback unbox-tuples* ;

: unbox-tuples ( nodes -- nodes )
    allocations get escaping-allocations get
    [ key? ] curry all-values?
    [ [ unbox-tuples* ] map-nodes ] unless ;
