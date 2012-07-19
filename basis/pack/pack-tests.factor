USING: io io.streams.string kernel namespaces make
pack strings tools.test pack.private ;
IN: pack.tests

[ B{ 1 0 2 0 0 3 0 0 0 4 0 0 0 0 0 0 0 5 } ] [
    { 1 2 3 4 5 }
    "cstiq" pack-be
] unit-test

[ { 1 2 3 4 5 } ] [
    { 1 2 3 4 5 }
    "cstiq" [ pack-be ] keep unpack-be
] unit-test

[ B{ 1 2 0 3 0 0 4 0 0 0 5 0 0 0 0 0 0 0 } ] [
    { 1 2 3 4 5 } "cstiq" pack-le
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

[ 9 ] [ "iic" packed-length ] unit-test
[ "iii" read-packed-le ] must-infer
[ "iii" read-packed-be ] must-infer
[ "iii" read-packed-native ] must-infer
[ "iii" unpack-le ] must-infer
[ "iii" unpack-be ] must-infer
[ "iii" unpack-native ] must-infer
[ "iii" pack ] must-infer
[ "iii" unpack ] must-infer

: test-pack ( str -- ba )
    "iii" pack ;

[ test-pack ] must-infer
