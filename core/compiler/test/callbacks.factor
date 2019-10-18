IN: temporary
USING: alien arrays compiler errors inference io kernel
kernel-internals math memory namespaces test threads words
prettyprint ;

: callback-1 "void" { } "cdecl" [ ] alien-callback ;

[ 0 1 ] [ [ callback-1 ] infer nip dup effect-in swap effect-out ] unit-test

[ t ] [ callback-1 alien? ] unit-test

: callback_test_1 "void" { } "cdecl" alien-indirect ;

[ ] [ callback-1 callback_test_1 ] unit-test

: callback-2 "void" { } "cdecl" [ [ 5 throw ] catch drop ] alien-callback ;

[ ] [ callback-2 callback_test_1 ] unit-test

: callback-3 "void" { } "cdecl" [ 5 "x" set ] alien-callback ;

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

: callback-4 "void" { } "cdecl" [ "Hello world" write ] alien-callback ;

[ "Hello world" ] [ 
    [ callback-4 callback_test_1 ] string-out
] unit-test

: callback-5
    "void" { } "cdecl" [ data-gc ] alien-callback ;

[ "testing" ] [
    "testing" callback-5 callback_test_1
] unit-test

: callback-5a
    "void" { } "cdecl" [ 8000000 f <array> drop ] alien-callback ;

[ "testing" ] [
    "testing" callback-5a callback_test_1
] unit-test

: callback-6
    "void" { } "cdecl" [ [ continue ] callcc0 ] alien-callback ;

[ 1 2 3 ] [ callback-6 callback_test_1 1 2 3 ] unit-test

: callback-7
    "void" { } "cdecl" [ 1000 sleep ] alien-callback ;

[ 1 2 3 ] [ callback-7 callback_test_1 1 2 3 ] unit-test

[ f ] [ namespace global eq? ] unit-test

: callback-8
    "void" { "int" "int" } "cdecl" [ / "x" set ] alien-callback ;

: callback_test_2
    "void" { "int" "int" } "cdecl" alien-indirect ;

[ 3/4 ] [
    [
        "x" off 3 4 callback-8 callback_test_2 "x" get
    ] with-scope
] unit-test

: callback-9
    "void" { "int" "double" "int" }
    "cdecl" [ + * "x" set ] alien-callback ;

: callback_test_3
    "void" { "int" "double" "int" } "cdecl" alien-indirect ;

[ 27.0 ] [
    [
        "x" off 3 4.0 5 callback-9 callback_test_3 "x" get
    ] with-scope
] unit-test

: callback-11 "int" { } "cdecl" [ 1234 ] alien-callback ;

: callback_test_5 "int" { } "cdecl" alien-indirect ;

[ 1234 ] [ callback-11 callback_test_5 ] unit-test

: callback-12 "float" { } "cdecl" [ pi ] alien-callback ;

: callback_test_6 "float" { } "cdecl" alien-indirect ;

[ t ] [ callback-12 callback_test_6 pi - 0.00001 <= ] unit-test

: callback-13 "double" { } "cdecl" [ pi ] alien-callback ;

: callback_test_7 "double" { } "cdecl" alien-indirect ;

[ t ] [ callback-13 callback_test_7 pi = ] unit-test

: callback-10
    "void"
    { "int" "int" "int" "int" "int" "int" "int" "int" "int" "int" }
    "cdecl" [ datastack "stack" set ] alien-callback ;

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
    "cdecl" [ dup foo-x dup . swap foo-y dup . / ] alien-callback ;

: callback_test_8 "int" { "foo" } "cdecl" alien-indirect ;

[ 5 ] [ 10 2 make-foo callback-14 callback_test_8 ] unit-test

! Callback scheduling issue
: callback_test_9 "int" { } "cdecl" alien-indirect ;

: callback-16
    "int" { } "cdecl" [
        yield 2
    ] alien-callback ;

: callback-15
    "int" { } "cdecl" [
        [ callback-16 callback_test_9 ] in-thread 3
    ] alien-callback ;

[ 3 ] [ callback-15 callback_test_9 ] unit-test

BEGIN-STRUCT: bar
    FIELD: long x
    FIELD: long y
    FIELD: long z
END-STRUCT

: make-bar ( x y z -- bar )
    "bar" <c-object>
    [ set-bar-z ] keep
    [ set-bar-y ] keep
    [ set-bar-x ] keep ;

: callback-17
    "bar" { "long" "long" "long" } "cdecl"
    [ make-bar ] alien-callback ;

: callback_test_10
    "bar" { "long" "long" "long" } "cdecl" alien-indirect ;

[ 1 2 3 ] [
    1 2 3 callback-17 callback_test_10
    dup bar-x over bar-y rot bar-z
] unit-test

: callback_test_11
    "int" { "int" "int" "int" "int" } "stdcall" alien-indirect ;

: callback-18
    "int" { "int" "int" "int" "int" } "stdcall"
    [ * + + ] alien-callback ;

[ 25 ] [
    2 3 4 5 callback-18 callback_test_11
] unit-test

: callback-19
    "bar" { "long" "long" "long" } "stdcall"
    [ make-bar ] alien-callback ;

: callback_test_12
    "bar" { "long" "long" "long" } "stdcall" alien-indirect ;

[ 11 6 -7 ] [
    11 6 -7 callback-19 callback_test_12
    dup bar-x over bar-y rot bar-z
] unit-test

BEGIN-STRUCT: tiny
    FIELD: int x
END-STRUCT

: callback-20
    "tiny" { "int" } "cdecl" [ <int> ] alien-callback ;

: callback_test_13
    "tiny" { "int" } "cdecl" alien-indirect ;

[ 176 ] [ 176 callback-20 callback_test_13 tiny-x ] unit-test

BEGIN-STRUCT: foo
    FIELD: long x
    FIELD: long y
END-STRUCT

: make-foo ( x y -- foo )
    "foo" <c-object> [ set-foo-y ] keep [ set-foo-x ] keep ;
    
: callback-21
    "foo" { "long" "long" } "cdecl"
    [ make-foo ] alien-callback ;

: callback_test_14
    "foo" { "long" "long" } "cdecl" alien-indirect ;

[ 69 73 ] [
    69 73 callback-21 callback_test_14 dup foo-x swap foo-y
] unit-test
