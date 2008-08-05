IN: compiler.tree.escape-analysis.tests
USING: compiler.tree.escape-analysis
compiler.tree.escape-analysis.allocations compiler.tree.builder
compiler.tree.normalization compiler.tree.copy-equiv
compiler.tree.propagation compiler.tree.cleanup
compiler.tree.combinators compiler.tree sequences math
kernel tools.test accessors slots.private quotations.private
prettyprint classes.tuple.private classes classes.tuple ;

\ escape-analysis must-infer

GENERIC: count-unboxed-allocations* ( m node -- n )

: (count-unboxed-allocations) ( m node -- n )
    out-d>> first escaping-allocation? [ 1+ ] unless ;

M: #call count-unboxed-allocations*
    dup word>> \ <tuple-boa> =
    [ (count-unboxed-allocations) ] [ drop ] if ;

M: #push count-unboxed-allocations*
    dup literal>> class immutable-tuple-class?
    [ (count-unboxed-allocations) ] [ drop ] if ;

M: node count-unboxed-allocations* drop ;

: count-unboxed-allocations ( quot -- sizes )
    build-tree
    normalize
    compute-copy-equiv
    propagate
    cleanup
    compute-copy-equiv
    escape-analysis
    0 swap [ count-unboxed-allocations* ] each-node ;

[ 0 ] [ [ [ + ] curry ] count-unboxed-allocations ] unit-test

[ 1 ] [ [ [ + ] curry drop ] count-unboxed-allocations ] unit-test

[ 1 ] [ [ [ + ] curry 3 slot ] count-unboxed-allocations ] unit-test

[ 1 ] [ [ [ + ] curry 3 slot drop ] count-unboxed-allocations ] unit-test

[ 1 ] [ [ [ + ] curry uncurry ] count-unboxed-allocations ] unit-test

[ 1 ] [ [ [ + ] curry call ] count-unboxed-allocations ] unit-test

[ 1 ] [ [ [ + ] curry call ] count-unboxed-allocations ] unit-test

[ 0 ] [ [ [ [ + ] curry ] [ drop [ ] ] if ] count-unboxed-allocations ] unit-test

[ 2 ] [
    [ [ [ + ] curry ] [ [ * ] curry ] if uncurry ] count-unboxed-allocations
] unit-test

[ 0 ] [
    [ [ [ + ] curry ] [ [ * ] curry ] if ] count-unboxed-allocations
] unit-test

[ 3 ] [
    [ [ [ + ] curry ] [ dup [ [ * ] curry ] [ [ / ] curry ] if ] if uncurry ] count-unboxed-allocations
] unit-test

[ 2 ] [
    [ [ [ + ] curry 4 ] [ dup [ [ * ] curry ] [ [ / ] curry ] if uncurry ] if ] count-unboxed-allocations
] unit-test

[ 0 ] [
    [ [ [ + ] curry ] [ dup [ [ * ] curry ] [ [ / ] curry ] if ] if ] count-unboxed-allocations
] unit-test

TUPLE: cons { car read-only } { cdr read-only } ;

[ 0 ] [
    [
        dup 0 = [
            2 cons boa
        ] [
            dup 1 = [
                3 cons boa
            ] when
        ] if car>>
    ] count-unboxed-allocations
] unit-test

[ 3 ] [
    [
        dup 0 = [
            2 cons boa
        ] [
            dup 1 = [
                3 cons boa
            ] [
                4 cons boa
            ] if
        ] if car>>
    ] count-unboxed-allocations
] unit-test

[ 0 ] [
    [
        dup 0 = [
            dup 1 = [
                3 cons boa
            ] [
                4 cons boa
            ] if
        ] unless car>>
    ] count-unboxed-allocations
] unit-test

[ 2 ] [
    [
        dup 0 = [
            2 cons boa
        ] [
            dup 1 = [
                3 cons boa
            ] [
                4 cons boa
            ] if car>>
        ] if
    ] count-unboxed-allocations
] unit-test

[ 0 ] [
    [
        dup 0 = [
            2 cons boa
        ] [
            dup 1 = [
                3 cons boa dup .
            ] [
                4 cons boa
            ] if
        ] if drop
    ] count-unboxed-allocations
] unit-test

[ 2 ] [
    [
        [ dup cons boa ] [ drop 1 2 cons boa ] if car>>
    ] count-unboxed-allocations
] unit-test

[ 2 ] [
    [
        3dup
        [ cons boa ] [ cons boa 3 cons boa ] if
        [ car>> ] [ cdr>> ] bi
    ] count-unboxed-allocations
] unit-test

[ 2 ] [
    [
        3dup [ cons boa ] [ cons boa . 1 2 cons boa ] if
        [ car>> ] [ cdr>> ] bi
    ] count-unboxed-allocations
] unit-test

[ 1 ] [
    [ [ 3 cons boa ] [ "A" throw ] if car>> ]
    count-unboxed-allocations
] unit-test

[ 0 ] [
    [ 10 [ drop ] each-integer ] count-unboxed-allocations
] unit-test

[ 2 ] [
    [
        1 2 cons boa 10 [ 2drop 1 2 cons boa ] each-integer car>>
    ] count-unboxed-allocations
] unit-test

[ 0 ] [
    [
        1 2 cons boa 10 [ drop 2 cons boa ] each-integer car>>
    ] count-unboxed-allocations
] unit-test

: infinite-cons-loop ( a -- b ) 2 cons boa infinite-cons-loop ; inline recursive

[ 0 ] [
    [
        1 2 cons boa infinite-cons-loop
    ] count-unboxed-allocations
] unit-test
