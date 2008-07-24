IN: compiler.tree.untupling.tests
USING: assocs math kernel quotations.private slots.private
compiler.tree.builder
compiler.tree.def-use
compiler.tree.copy-equiv
compiler.tree.untupling
tools.test ;

: check-untupling ( quot -- sizes )
    build-tree
    compute-copy-equiv
    compute-def-use
    compute-untupling
    values ;

[ { } ] [ [ 1 [ + ] curry ] check-untupling ] unit-test

[ { 2 } ] [ [ 1 [ + ] curry drop ] check-untupling ] unit-test

[ { 2 } ] [ [ 1 [ + ] curry 3 slot ] check-untupling ] unit-test

[ { 2 } ] [ [ 1 [ + ] curry 3 slot drop ] check-untupling ] unit-test

[ { 2 } ] [ [ 1 [ + ] curry uncurry ] check-untupling ] unit-test

[ { 2 } ] [ [ 2 1 [ + ] curry call ] check-untupling ] unit-test

[ { 2 } ] [ [ 2 1 [ + ] curry call ] check-untupling ] unit-test

[ { } ] [ [ [ 1 [ + ] curry ] [ [ ] ] if ] check-untupling ] unit-test

[ { 2 2 } ] [
    [ [ 1 [ + ] curry ] [ 2 [ * ] curry ] if uncurry ] check-untupling
] unit-test

[ { } ] [
    [ [ 1 [ + ] curry ] [ 2 [ * ] curry ] if ] check-untupling
] unit-test

[ { 2 2 2 } ] [
    [ [ 1 [ + ] curry ] [ dup [ 2 [ * ] curry ] [ 3 [ / ] curry ] if ] if uncurry ] check-untupling
] unit-test

[ { 2 2 } ] [
    [ [ 1 [ + ] curry 4 ] [ dup [ 2 [ * ] curry ] [ 3 [ / ] curry ] if uncurry ] if ] check-untupling
] unit-test

[ { } ] [
    [ [ 1 [ + ] curry ] [ dup [ 2 [ * ] curry ] [ 3 [ / ] curry ] if ] if ] check-untupling
] unit-test
