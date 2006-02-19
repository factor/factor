IN: temporary
USING: alien compiler errors inference io kernel math memory
namespaces test threads ;

: callback-1 "void" { } [ ] alien-callback ; compiled

[ { 0 1 } ] [ [ callback-1 ] infer ] unit-test

[ t ] [ callback-1 alien? ] unit-test

FUNCTION: void callback_test_1 void* callback ; compiled

[ ] [ callback-1 callback_test_1 ] unit-test

: callback-2 "void" { } [ 5 throw ] alien-callback ; compiled

[ 5 ] [ [ callback-2 callback_test_1 ] catch ] unit-test

: callback-3 "void" { } [ 5 "x" set ] alien-callback ; compiled

[ t ] [ 
    namestack*
    3 "x" set callback-3 callback_test_1
    namestack* eq?
] unit-test

[ 5 ] [ 
    [
        3 "x" set callback-3 callback_test_1 "x" get
    ] with-scope
] unit-test

: callback-4 "void" { } [ "Hello world" write ] alien-callback ; compiled

[ "Hello world" ] [ 
    [ callback-4 callback_test_1 ] string-out
] unit-test

: callback-5
    "void" { } [ full-gc ] alien-callback ; compiled

[ "testing" ] [
    "testing" callback-5 callback_test_1
] unit-test

: callback-6
    "void" { } [ [ continue ] callcc0 ] alien-callback ; compiled

[ ] [ callback-6 callback_test_1 ] unit-test

: callback-7
    "void" { } [ yield "hi" print flush yield ] alien-callback ; compiled

[ ] [ callback-7 callback_test_1 ] unit-test

: callback-8
    "void" { "int" "int" } [ / "x" set ] alien-callback ;
    compiled

FUNCTION: void callback_test_2 void* callback int x int y ;
compiled

[ 3/4 ] [
    [
        "x" off callback-8 3 4 callback_test_2 "x" get
    ] with-scope
] unit-test

: callback-9
    "void" { "int" "double" "int" }
    [ + * "x" set ] alien-callback ; compiled

FUNCTION: void callback_test_3 void* callback int x double y int z ; compiled

[ 27.0 ] [
    [
        "x" off callback-9 3 4 5 callback_test_3 "x" get
    ] with-scope
] unit-test

: callback-10
    "void"
    { "int" "int" "int" "int" "int" "int" "int" "int" "int" "int" }
    [ datastack "stack" set ] alien-callback ; compiled

FUNCTION: void callback_test_4 void* callback int a1 int a2 int a3 int a4 int a5 int a6 int a7 int a8 int a9 int a10 ; compiled

[ V{ 1 2 3 4 5 6 7 8 9 10 } ] [
    [
        callback-10 1 2 3 4 5 6 7 8 9 10 callback_test_4
        "stack" get
    ] with-scope
] unit-test

: callback-11 "int" { } [ 1234 ] alien-callback ; compiled

FUNCTION: int callback_test_5 void* callback ; compiled

[ 1234 ] [ callback-11 callback_test_5 ] unit-test

: callback-12 "float" { } [ pi ] alien-callback ; compiled

FUNCTION: float callback_test_6 void* callback ; compiled

[ t ] [ callback-12 callback_test_6 pi - 0.00001 <= ] unit-test

: callback-13 "double" { } [ pi ] alien-callback ; compiled

FUNCTION: double callback_test_7 void* callback ; compiled

[ t ] [ callback-13 callback_test_7 pi = ] unit-test
