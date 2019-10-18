IN: temporary
USING: alien compiler errors inference io kernel
kernel-internals math memory namespaces test threads ;

: callback-1 "void" { } [ ] alien-callback ;

[ { 0 1 } ] [ [ callback-1 ] infer ] unit-test

[ t ] [ callback-1 alien? ] unit-test

: callback_test_1 "void" { } "cdecl" alien-indirect ;

[ ] [ callback-1 callback_test_1 ] unit-test

: callback-2 "void" { } [ [ 5 throw ] catch drop ] alien-callback ;

[ ] [ callback-2 callback_test_1 ] unit-test

: callback-3 "void" { } [ 5 "x" set ] alien-callback ;

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

: callback-4 "void" { } [ "Hello world" write ] alien-callback ;

[ "Hello world" ] [ 
    [ callback-4 callback_test_1 ] string-out
] unit-test

: callback-5
    "void" { } [ full-gc ] alien-callback ;

[ "testing" ] [
    "testing" callback-5 callback_test_1
] unit-test

: callback-6
    "void" { } [ [ continue ] callcc0 ] alien-callback ;

[ 1 2 3 ] [ callback-6 callback_test_1 1 2 3 ] unit-test

: callback-7
    "void" { } [ yield "hi" print flush yield ] alien-callback ;

[ 1 2 3 ] [ callback-7 callback_test_1 1 2 3 ] unit-test

: callback-8
    "void" { "int" "int" } [ / "x" set ] alien-callback ;
   

: callback_test_2
    "void" { "int" "int" } "cdecl" alien-indirect ;

[ 3/4 ] [
    [
        "x" off 3 4 callback-8 callback_test_2 "x" get
    ] with-scope
] unit-test

: callback-9
    "void" { "int" "double" "int" }
    [ + * "x" set ] alien-callback ;

: callback_test_3
    "void" { "int" "double" "int" } "cdecl" alien-indirect ;

[ 27.0 ] [
    [
        "x" off 3 4 5 callback-9 callback_test_3 "x" get
    ] with-scope
] unit-test

: callback-11 "int" { } [ 1234 ] alien-callback ;

: callback_test_5 "int" { } "cdecl" alien-indirect ;

[ 1234 ] [ callback-11 callback_test_5 ] unit-test

: callback-12 "float" { } [ pi ] alien-callback ;

: callback_test_6 "float" { } "cdecl" alien-indirect ;

[ t ] [ callback-12 callback_test_6 pi - 0.00001 <= ] unit-test

: callback-13 "double" { } [ pi ] alien-callback ;

: callback_test_7 "double" { } "cdecl" alien-indirect ;

[ t ] [ callback-13 callback_test_7 pi = ] unit-test

: callback-10
    "void"
    { "int" "int" "int" "int" "int" "int" "int" "int" "int" "int" }
    [ datastack "stack" set ] alien-callback ;

: callback_test_4
    "void"
    { "int" "int" "int" "int" "int" "int" "int" "int" "int" "int" }
    "cdecl"
    alien-indirect ;

[ V{ 1 2 3 4 5 6 7 8 9 10 } ] [
    [
        1 2 3 4 5 6 7 8 9 10 callback-10 callback_test_4
        "stack" get
    ] with-scope
] unit-test

BEGIN-STRUCT: foo
    FIELD: int x
    FIELD: int y
END-STRUCT

: make-foo ( x y -- foo )
    "foo" <c-object> [ set-foo-y ] keep [ set-foo-x ] keep ;

: callback-14
    "int"
    { "foo" }
    [ dup foo-x swap foo-y / ] alien-callback ;

: callback_test_8 "int" { "foo" } "cdecl" alien-indirect ;

[ 5 ] [ 10 2 make-foo callback-14 callback_test_8 ] unit-test
