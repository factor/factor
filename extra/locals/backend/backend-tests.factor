IN: locals.backend.tests
USING: tools.test locals.backend kernel arrays ;

[ 3 ] [ 3 >r 1 get-local r> drop ] unit-test

[ 4 ] [ 3 4 >r >r 2 get-local 2 drop-locals ] unit-test

: get-local-test-1 3 >r 1 get-local r> drop ;

{ 0 1 } [ get-local-test-1 ] must-infer-as

[ 3 ] [ get-local-test-1 ] unit-test

: get-local-test-2 3 4 >r >r 2 get-local 2 drop-locals ;

{ 0 1 } [ get-local-test-2 ] must-infer-as

[ 4 ] [ get-local-test-2 ] unit-test

: get-local-test-3 3 4 >r >r 2 get-local r> r> 2array ;

{ 0 2 } [ get-local-test-3 ] must-infer-as

[ 4 { 3 4 } ] [ get-local-test-3 ] unit-test

: get-local-test-4 3 4 >r >r r> r> dup swap >r swap >r r> r> 2array ;

{ 0 2 } [ get-local-test-4 ] must-infer-as

[ 4 { 3 4 } ] [ get-local-test-4 ] unit-test

[ 1 2 ] [ 1 2 2 load-locals r> r> ] unit-test

: load-locals-test-1 1 2 2 load-locals r> r> ;

{ 0 2 } [ load-locals-test-1 ] must-infer-as

[ 1 2 ] [ load-locals-test-1 ] unit-test
