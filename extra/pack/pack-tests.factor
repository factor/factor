USING: io io.streams.string kernel namespaces pack strings tools.test ;

[ B{ 1 0 2 0 0 3 0 0 0 4 0 0 0 0 0 0 0 5 } ] [
    { 1 2 3 4 5 }
    "cstiq" pack-be
] unit-test

[ { 1 2 3 4 5 } ] [
    { 1 2 3 4 5 }
    "cstiq" [ pack-be ] keep unpack-be
] unit-test

[ B{ 1 2 0 3 0 0 4 0 0 0 5 0 0 0 0 0 0 0 } ] [
    [
        { 1 2 3 4 5 } "cstiq" pack-le
    ] with-scope
] unit-test

[ { 1 2 3 4 5 } ] [
    { 1 2 3 4 5 }
    "cstiq" [ pack-le ] keep unpack-le
] unit-test

[ { -1 -2 -3 -4 -5 } ] [
    { -1 -2 -3 -4 -5 }
    "cstiq" [ pack-le ] keep unpack-le
] unit-test

[ { -1 -2 -3 -4 -5 3.14 } ] [
    { -1 -2 -3 -4 -5 3.14 }
    "cstiqd" [ pack-be ] keep unpack-be
] unit-test

[ { -1 -2 -3 -4 -5 } ] [
    { -1 -2 -3 -4 -5 }
    "cstiq" [ pack-native ] keep unpack-native
] unit-test

[ 2 ] [
    [ 2 "int" b, ] B{ } make
    <string-reader> [ "int" read-native ] with-stream
] unit-test

[ "FRAM" ] [ "FRAM\0" [ read-c-string ] string-in ] unit-test
[ f ] [ "" [ read-c-string ] string-in ] unit-test
[ 5 ] [ "FRAM\0\u0005\0\0\0\0\0\0\0" [ read-c-string drop read-u64 ] string-in ] unit-test

