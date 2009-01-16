USING: io io.streams.string kernel namespaces make
pack strings tools.test ;

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
    <string-reader> [ "int" read-native ] with-input-stream
] unit-test

[ "FRAM" ] [ "FRAM\0" [ read-c-string ] with-string-reader ] unit-test
[ f ] [ "" [ read-c-string ] with-string-reader ] unit-test
[ 5 ] [ "FRAM\0\u000005\0\0\0\0\0\0\0" [ read-c-string drop read-u64 ] with-string-reader ] unit-test

[ 9 ] [ "iic" packed-length ] unit-test
[ "iii" read-packed-le ] must-infer
[ "iii" unpack-le ] must-infer
[ "iii" unpack-be ] must-infer
[ "iii" unpack-native ] must-infer
