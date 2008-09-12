IN: locals.backend.tests
USING: tools.test locals.backend kernel arrays ;

[ 3 ] [ 3 >r 1 get-local r> drop ] unit-test

[ 4 ] [ 3 4 >r >r 2 get-local 2 drop-locals ] unit-test

: get-local-test-1 ( -- x ) 3 >r 1 get-local r> drop ;

\ get-local-test-1 must-infer

[ 3 ] [ get-local-test-1 ] unit-test

: get-local-test-2 ( -- x ) 3 4 >r >r 2 get-local 2 drop-locals ;

\ get-local-test-2 must-infer

[ 4 ] [ get-local-test-2 ] unit-test

: get-local-test-3 ( -- a b ) 3 4 >r >r 2 get-local r> r> 2array ;

\ get-local-test-3 must-infer

[ 4 { 3 4 } ] [ get-local-test-3 ] unit-test

: get-local-test-4 ( -- a b )
    3 4 >r >r r> r> dup swap >r swap >r r> r> 2array ;

\ get-local-test-4 must-infer

[ 4 { 3 4 } ] [ get-local-test-4 ] unit-test

[ 1 2 ] [ 1 2 2 load-locals r> r> ] unit-test

: load-locals-test-1 ( -- a b ) 1 2 2 load-locals r> r> ;

\ load-locals-test-1 must-infer

[ 1 2 ] [ load-locals-test-1 ] unit-test
