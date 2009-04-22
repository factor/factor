USING: tools.test kernel accessors ;
IN: calendar.format.macros

[ 2 ] [ { [ 2 ] } attempt-all-quots ] unit-test

[ 2 ] [ { [ 1 throw ] [ 2 ] } attempt-all-quots ] unit-test

[ { [ 1 throw ] } attempt-all-quots ] [ 1 = ] must-fail-with

: compiled-test-1 ( -- n )
    { [ 1 throw ] [ 2 ] } attempt-all-quots ;

\ compiled-test-1 def>> must-infer

[ 2 ] [ compiled-test-1 ] unit-test
