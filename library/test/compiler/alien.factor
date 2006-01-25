USING: compiler test ;

FUNCTION: void ffi_test_0 ; compiled
[ ] [ ffi_test_0 ] unit-test

FUNCTION: int ffi_test_1 ; compiled
[ 3 ] [ ffi_test_1 ] unit-test

FUNCTION: int ffi_test_2 int x int y ; compiled
[ 5 ] [ 2 3 ffi_test_2 ] unit-test

FUNCTION: int ffi_test_3 int x int y int z int t ; compiled
[ 25 ] [ 2 3 4 5 ffi_test_3 ] unit-test

