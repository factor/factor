USING: namespaces assocs sequences compiler.tree.builder
compiler.tree.dead-code compiler.tree.def-use compiler.tree
compiler.tree.combinators compiler.tree.debugger
compiler.tree.normalization tools.test
kernel math stack-checker.state accessors combinators io ;
IN: compiler.tree.dead-code.tests

\ remove-dead-code must-infer

: count-live-values ( quot -- n )
    build-tree
    normalize
    compute-def-use
    remove-dead-code
    0 swap [
        {
            { [ dup #push? ] [ out-d>> length + ] }
            { [ dup #introduce? ] [ drop 1 + ] }
            [ drop ]
        } cond
    ] each-node ;

[ 3 ] [ [ 1 2 3 ] count-live-values ] unit-test

[ 1 ] [ [ drop ] count-live-values ] unit-test

[ 0 ] [ [ 1 drop ] count-live-values ] unit-test

[ 1 ] [ [ 1 2 drop ] count-live-values ] unit-test

[ 3 ] [ [ [ 1 ] [ 2 ] if ] count-live-values ] unit-test

[ 1 ] [ [ [ 1 ] [ 2 ] if drop ] count-live-values ] unit-test

[ 2 ] [ [ [ 1 ] [ dup ] if drop ] count-live-values ] unit-test

[ 2 ] [ [ 1 2 + ] count-live-values ] unit-test

[ 0 ] [ [ 1 2 + drop ] count-live-values ] unit-test

[ 3 ] [ [ 1 2 + 3 + ] count-live-values ] unit-test

[ 0 ] [ [ 1 2 + 3 + drop ] count-live-values ] unit-test

[ 4 ] [ [ [ 1 ] [ 2 ] if 3 + ] count-live-values ] unit-test

[ 1 ] [ [ [ 1 ] [ 2 ] if 3 + drop ] count-live-values ] unit-test

[ 0 ] [ [ [ ] call ] count-live-values ] unit-test

[ 1 ] [ [ [ 1 ] call ] count-live-values ] unit-test

[ 2 ] [ [ [ 1 ] [ 2 ] compose call ] count-live-values ] unit-test

[ 0 ] [ [ [ 1 ] [ 2 ] compose call + drop ] count-live-values ] unit-test

: optimize-quot ( quot -- quot' )
    build-tree normalize compute-def-use remove-dead-code
    nodes>quot ;

[ [ drop 1 ] ] [ [ >r 1 r> drop ] optimize-quot ] unit-test

[ [ read 1 2 ] ] [ [ read >r 1 2 r> drop ] optimize-quot ] unit-test

[ [ over >r + r> ] ] [ [ [ + ] [ drop ] 2bi ] optimize-quot ] unit-test
