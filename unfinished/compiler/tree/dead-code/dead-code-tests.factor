USING: namespaces assocs sequences compiler.tree.builder
compiler.tree.dead-code compiler.tree.def-use compiler.tree
compiler.tree.combinators tools.test kernel math
stack-checker.state accessors ;
IN: compiler.tree.dead-code.tests

\ remove-dead-code must-infer

: count-live-values ( quot -- n )
    build-tree
    compute-def-use
    remove-dead-code
    compute-def-use
    0 swap [ dup #push? [ out-d>> length + ] [ drop ] if ] each-node ;

[ 3 ] [ [ 1 2 3 ] count-live-values ] unit-test

[ 0 ] [ [ 1 drop ] count-live-values ] unit-test

[ 1 ] [ [ 1 2 drop ] count-live-values ] unit-test

[ 2 ] [ [ [ 1 ] [ 2 ] if ] count-live-values ] unit-test

[ 0 ] [ [ [ 1 ] [ 2 ] if drop ] count-live-values ] unit-test

[ 0 ] [ [ [ 1 ] [ dup ] if drop ] count-live-values ] unit-test

[ 2 ] [ [ 1 2 + ] count-live-values ] unit-test

[ 0 ] [ [ 1 2 + drop ] count-live-values ] unit-test

[ 3 ] [ [ 1 2 + 3 + ] count-live-values ] unit-test

[ 0 ] [ [ 1 2 + 3 + drop ] count-live-values ] unit-test

[ 3 ] [ [ [ 1 ] [ 2 ] if 3 + ] count-live-values ] unit-test

[ 0 ] [ [ [ 1 ] [ 2 ] if 3 + drop ] count-live-values ] unit-test

[ 0 ] [ [ [ ] call ] count-live-values ] unit-test

[ 1 ] [ [ [ 1 ] call ] count-live-values ] unit-test

[ 2 ] [ [ [ 1 ] [ 2 ] compose call ] count-live-values ] unit-test

[ 0 ] [ [ [ 1 ] [ 2 ] compose call + drop ] count-live-values ] unit-test
