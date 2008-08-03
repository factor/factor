IN: compiler.tree.escape-analysis.tests
USING: compiler.tree.escape-analysis
compiler.tree.escape-analysis.allocations compiler.tree.builder
compiler.tree.normalization compiler.tree.copy-equiv
compiler.tree.propagation compiler.tree.cleanup
compiler.tree.combinators compiler.tree sequences math
kernel tools.test accessors slots.private quotations.private
prettyprint classes.tuple.private ;

\ escape-analysis must-infer

: count-unboxed-allocations ( quot -- sizes )
    build-tree
    normalize
    compute-copy-equiv
    propagate
    cleanup
    escape-analysis
    0 swap [
        dup #call?
        [
            dup word>> \ <tuple-boa> = [
                out-d>> first escaping-allocation? [ 1+ ] unless
            ] [ drop ] if
        ] [ drop ] if
    ] each-node ;

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
