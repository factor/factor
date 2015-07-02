IN: locals.backend.tests
USING: tools.test locals.backend kernel arrays accessors ;

: get-local-test-1 ( -- x ) 3 1 load-locals 0 get-local 1 drop-locals ;

\ get-local-test-1 def>> must-infer

[ 3 ] [ get-local-test-1 ] unit-test

: get-local-test-2 ( -- x ) 3 4 2 load-locals -1 get-local 2 drop-locals ;

\ get-local-test-2 def>> must-infer

[ 3 ] [ get-local-test-2 ] unit-test
