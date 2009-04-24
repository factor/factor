IN: compiler.tree.escape-analysis.tests
USING: compiler.tree.escape-analysis
compiler.tree.escape-analysis.allocations compiler.tree.builder
compiler.tree.recursive compiler.tree.normalization
math.functions compiler.tree.propagation compiler.tree.cleanup
compiler.tree.combinators compiler.tree sequences math
math.private kernel tools.test accessors slots.private
quotations.private prettyprint classes.tuple.private classes
classes.tuple namespaces
compiler.tree.propagation.info stack-checker.errors
compiler.tree.checker
kernel.private ;

GENERIC: count-unboxed-allocations* ( m node -- n )

: (count-unboxed-allocations) ( m node -- n )
    out-d>> first escaping-allocation? [ 1+ ] unless ;

M: #call count-unboxed-allocations*
    dup [ immutable-tuple-boa? ] [ word>> \ <complex> eq? ] bi or
    [ (count-unboxed-allocations) ] [ drop ] if ;

M: #push count-unboxed-allocations*
    dup literal>> class immutable-tuple-class?
    [ (count-unboxed-allocations) ] [ drop ] if ;

M: node count-unboxed-allocations* drop ;

: count-unboxed-allocations ( quot -- sizes )
    build-tree
    analyze-recursive
    normalize
    propagate
    cleanup
    escape-analysis
    dup check-nodes
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

TUPLE: rw-box i ;

C: <rw-box> rw-box

[ 0 ] [ [ <rw-box> i>> ] count-unboxed-allocations ] unit-test

: fake-fib ( m -- n )
    dup i>> 1 <= [ drop 1 <rw-box> ] when ; inline recursive

[ 0 ] [ [ <rw-box> fake-fib i>> ] count-unboxed-allocations ] unit-test

TUPLE: ro-box { i read-only } ;

C: <ro-box> ro-box

: tuple-fib ( m -- n )
    dup i>> 1 <= [
        drop 1 <ro-box>
    ] [
        i>> 1- <ro-box>
        dup tuple-fib
        swap
        i>> 1- <ro-box>
        tuple-fib
        swap i>> swap i>> + <ro-box>
    ] if ; inline recursive

[ 5 ] [ [ <ro-box> tuple-fib i>> ] count-unboxed-allocations ] unit-test

[ 3 ] [ [ <ro-box> tuple-fib ] count-unboxed-allocations ] unit-test

: tuple-fib' ( m -- n )
    dup 1 <= [ 1- tuple-fib' i>> ] when <ro-box> ; inline recursive

[ 0 ] [ [ tuple-fib' ] count-unboxed-allocations ] unit-test

: bad-tuple-fib-1 ( m -- n )
    dup i>> 1 <= [
        drop 1 <ro-box>
    ] [
        i>> 1- <ro-box>
        dup bad-tuple-fib-1
        swap
        i>> 1- <ro-box>
        bad-tuple-fib-1 dup .
        swap i>> swap i>> + <ro-box>
    ] if ; inline recursive

[ 3 ] [ [ <ro-box> bad-tuple-fib-1 i>> ] count-unboxed-allocations ] unit-test

: bad-tuple-fib-2 ( m -- n )
    dup .
    dup i>> 1 <= [
        drop 1 <ro-box>
    ] [
        i>> 1- <ro-box>
        dup bad-tuple-fib-2
        swap
        i>> 1- <ro-box>
        bad-tuple-fib-2
        swap i>> swap i>> + <ro-box>
    ] if ; inline recursive

[ 2 ] [ [ <ro-box> bad-tuple-fib-2 i>> ] count-unboxed-allocations ] unit-test

: tuple-fib-2 ( m -- n )
    dup 1 <= [
        drop 1 <ro-box>
    ] [
        1- dup tuple-fib-2
        swap
        1- tuple-fib-2
        swap i>> swap i>> + <ro-box>
    ] if ; inline recursive

[ 2 ] [ [ tuple-fib-2 i>> ] count-unboxed-allocations ] unit-test

: tuple-fib-3 ( m -- n )
    dup 1 <= [
        drop 1 <ro-box>
    ] [
        1- dup tuple-fib-3
        swap
        1- tuple-fib-3 dup .
        swap i>> swap i>> + <ro-box>
    ] if ; inline recursive

[ 0 ] [ [ tuple-fib-3 i>> ] count-unboxed-allocations ] unit-test

: bad-tuple-fib-3 ( m -- n )
    dup 1 <= [
        drop 1 <ro-box>
    ] [
        1- dup bad-tuple-fib-3
        swap
        1- bad-tuple-fib-3
        2drop f
    ] if ; inline recursive

[ 0 ] [ [ bad-tuple-fib-3 i>> ] count-unboxed-allocations ] unit-test

[ 1 ] [ [ <complex> >rect ] count-unboxed-allocations ] unit-test

[ 0 ] [ [ 1 cons boa 2 cons boa ] count-unboxed-allocations ] unit-test

[ 1 ] [ [ 1 cons boa 2 cons boa car>> ] count-unboxed-allocations ] unit-test

[ 0 ] [ [ 1 cons boa 2 cons boa dup . car>> ] count-unboxed-allocations ] unit-test

[ 0 ] [ [ 1 cons boa "x" get slot ] count-unboxed-allocations ] unit-test

: impeach-node ( quot: ( node -- ) -- )
    dup slip impeach-node ; inline recursive

: bleach-node ( quot: ( node -- ) -- )
    [ bleach-node ] curry [ ] compose impeach-node ; inline recursive

[ 3 ] [ [ [ ] bleach-node ] count-unboxed-allocations ] unit-test

[ 0 ] [
    [ dup -1 over >= [ 0 >= [ "A" throw ] unless ] [ drop ] if ]
    count-unboxed-allocations
] unit-test

[ 0 ] [
    [ \ too-many->r boa f f \ inference-error boa ]
    count-unboxed-allocations
] unit-test

[ 0 ] [
    [ { null } declare [ 1 ] [ 2 ] if ] count-unboxed-allocations
] unit-test
