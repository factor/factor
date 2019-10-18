IN: temporary
USING: inference generator optimizer compiler kernel
kernel-internals test math-internals ;

: no-stack-frame?
    dataflow optimize stack-frame-size no-stack-frame = ;

: no-label-stack-frame?
    dataflow optimize node-child
    stack-frame-size no-stack-frame = ;

[ t ] [ [ 1 2 3 ] no-stack-frame? ] unit-test

: foo ;

[ f ] [ [ 1 foo 2 3 ] no-stack-frame? ] unit-test

[ t ] [ [ 1 2 3 foo ] no-stack-frame? ] unit-test

[ t ] [ [ [ 1 2 3 foo ] [ 4 5 6 ] if ] no-stack-frame? ] unit-test

[ f ] [ [ [ 1 2 foo 3 ] [ 4 5 6 ] if ] no-stack-frame? ] unit-test

[ f ] [ [ [ 1 2 3 foo ] [ 4 5 6 ] if 7 ] no-stack-frame? ] unit-test

: rec1 ( -- ) rec1 foo ; inline

[ t ] [ [ rec1 ] no-stack-frame? ] unit-test
[ f ] [ [ rec1 ] no-label-stack-frame? ] unit-test

: rec1/2 ( ? -- ) [ f rec1/2 ] when ; inline

[ t ] [ [ rec1/2 ] no-stack-frame? ] unit-test
[ t ] [ [ rec1/2 ] no-label-stack-frame? ] unit-test

: rec2 ( -- ) rec2 ; inline

[ t ] [ [ rec2 ] no-stack-frame? ] unit-test

[ t ] [ [ { [ ] [ ] } dispatch ] no-stack-frame? ] unit-test

[ t ] [ [ { [ foo ] [ ] } dispatch ] no-stack-frame? ] unit-test

[ t ] [ [ { [ foo 3 ] [ 4 ] } dispatch ] no-stack-frame? ] unit-test

[ f ] [ [ { [ ] [ ] } dispatch foo ] no-stack-frame? ] unit-test

[ t ] [ [ fixnum+fast 3 ] no-stack-frame? ] unit-test
