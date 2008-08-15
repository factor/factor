USING: namespaces assocs sequences compiler.tree.builder
compiler.tree.dead-code compiler.tree.def-use compiler.tree
compiler.tree.combinators compiler.tree.propagation
compiler.tree.cleanup compiler.tree.escape-analysis
compiler.tree.tuple-unboxing compiler.tree.debugger
compiler.tree.normalization compiler.tree.checker tools.test
kernel math stack-checker.state accessors combinators io ;
IN: compiler.tree.dead-code.tests

\ remove-dead-code must-infer

: count-live-values ( quot -- n )
    build-tree
    normalize
    propagate
    cleanup
    escape-analysis
    unbox-tuples
    compute-def-use
    remove-dead-code
    0 swap [
        dup
        [ #push? ] [ #introduce? ] bi or
        [ out-d>> length + ] [ drop ] if
    ] each-node ;

[ 3 ] [ [ 1 2 3 ] count-live-values ] unit-test

[ 1 ] [ [ drop ] count-live-values ] unit-test

[ 0 ] [ [ 1 drop ] count-live-values ] unit-test

[ 1 ] [ [ 1 2 drop ] count-live-values ] unit-test

[ 3 ] [ [ [ 1 ] [ 2 ] if ] count-live-values ] unit-test

[ 1 ] [ [ [ 1 ] [ 2 ] if drop ] count-live-values ] unit-test

[ 2 ] [ [ [ 1 ] [ dup ] if drop ] count-live-values ] unit-test

[ 2 ] [ [ 1 + ] count-live-values ] unit-test

[ 0 ] [ [ 1 2 + drop ] count-live-values ] unit-test

[ 3 ] [ [ 1 + 3 + ] count-live-values ] unit-test

[ 0 ] [ [ 1 2 + 3 + drop ] count-live-values ] unit-test

[ 4 ] [ [ [ 1 ] [ 2 ] if 3 + ] count-live-values ] unit-test

[ 1 ] [ [ [ 1 ] [ 2 ] if 3 + drop ] count-live-values ] unit-test

[ 0 ] [ [ [ ] call ] count-live-values ] unit-test

[ 1 ] [ [ [ 1 ] call ] count-live-values ] unit-test

[ 2 ] [ [ [ 1 ] [ 2 ] compose call ] count-live-values ] unit-test

[ 0 ] [ [ [ 1 ] [ 2 ] compose call + drop ] count-live-values ] unit-test

[ 3 ] [ [ 10 [ ] times ] count-live-values ] unit-test

: optimize-quot ( quot -- quot' )
    build-tree
    normalize
    propagate
    cleanup
    escape-analysis
    unbox-tuples
    compute-def-use
    remove-dead-code
    "no-check" get [ dup check-nodes ] unless nodes>quot ;

[ [ drop 1 ] ] [ [ >r 1 r> drop ] optimize-quot ] unit-test

[ [ read drop 1 2 ] ] [ [ read >r 1 2 r> drop ] optimize-quot ] unit-test

[ [ over >r + r> ] ] [ [ [ + ] [ drop ] 2bi ] optimize-quot ] unit-test

[ [ [ ] [ ] if ] ] [ [ [ 1 ] [ 2 ] if drop ] optimize-quot ] unit-test

: flushable-1 ( a b -- c ) 2drop f ; flushable
: flushable-2 ( a b -- c ) 2drop f ; flushable

[ [ 2nip [ ] [ ] if ] ] [
    [ [ flushable-1 ] [ flushable-2 ] if drop ] optimize-quot
] unit-test

: non-flushable-3 ( a b -- c ) 2drop f ;

[ [ [ drop drop ] [ non-flushable-3 drop ] if ] ] [
    [ [ flushable-1 ] [ non-flushable-3 ] if drop ] optimize-quot
] unit-test

[ [ [ f ] [ f ] if ] ] [ [ [ f ] [ f ] if ] optimize-quot ] unit-test

[ ] [ [ dup [ 3 throw ] [ ] if ] optimize-quot drop ] unit-test

: non-flushable-4 ( a -- b ) drop f ;

: recursive-test-1 ( a b -- )
    dup 10 < [
        >r drop 5 non-flushable-4 r> 1 + recursive-test-1
    ] [ 2drop ] if ; inline recursive
