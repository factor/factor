IN: temporary
USING: alien compiler inference namespaces test ;

: no-op ;

: callback-1 "void" { } \ no-op alien-callback ; compiled

[ { 0 1 } ] [ [ callback-1 ] infer ] unit-test

: callback-1-bad "int" { } \ no-op alien-callback ;

[ [ callback-1-bad ] infer ] unit-test-fails

[ t ] [ callback-1 alien? ] unit-test

FUNCTION: void callback_test_1 void* callback ; compiled

[ ] [ callback-1 callback_test_1 ] unit-test
