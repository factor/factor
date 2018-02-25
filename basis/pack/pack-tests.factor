USING: alien.c-types io io.streams.string kernel make namespaces
pack pack.private strings tools.test ;

{ B{ 1 0 2 0 0 3 0 0 0 4 0 0 0 0 0 0 0 5 } } [
    { 1 2 3 4 5 }
    "cstiq" pack-be
] unit-test

{ { 1 2 3 4 5 } } [
    { 1 2 3 4 5 }
    "cstiq" [ pack-be ] keep unpack-be
] unit-test

{ B{ 1 2 0 3 0 0 4 0 0 0 5 0 0 0 0 0 0 0 } } [
    { 1 2 3 4 5 } "cstiq" pack-le
] unit-test

{ { 1 2 3 4 5 } } [
    { 1 2 3 4 5 }
    "cstiq" [ pack-le ] keep unpack-le
] unit-test

{ { -1 -2 -3 -4 -5 } } [
    { -1 -2 -3 -4 -5 }
    "cstiq" [ pack-le ] keep unpack-le
] unit-test

{ { -1 -2 -3 -4 -5 3.14 } } [
    { -1 -2 -3 -4 -5 3.14 }
    "cstiqd" [ pack-be ] keep unpack-be
] unit-test

{ { -1 -2 -3 -4 -5 } } [
    { -1 -2 -3 -4 -5 }
    "cstiq" [ pack-native ] keep unpack-native
] unit-test

{ B{ 1 2 3 4 5 0 0 0 } } [ { 1 2 3 4 5 } "4ci" pack-le ] unit-test
{ { 1 2 3 4 5 } } [ B{ 1 2 3 4 5 0 0 0 } "4ci" unpack-le ] unit-test

{ 9 } [ "iic" packed-length ] unit-test
[ "iii" read-packed-le ] must-infer
[ "iii" read-packed-be ] must-infer
[ "iii" read-packed-native ] must-infer
[ "iii" unpack-le ] must-infer
[ "iii" unpack-be ] must-infer
[ "iii" unpack-native ] must-infer
[ "iii" pack ] must-infer
[ "iii" unpack ] must-infer

[ "iii" pack ] must-infer

{ "c" } [ "1c" expand-pack-format ] unit-test
{ "cccc" } [ "4c" expand-pack-format ] unit-test
{ "cccccccccccc" } [ "12c" expand-pack-format ] unit-test
{ "iccqqq" } [ "1i2c3q" expand-pack-format ] unit-test

{ B{ 1 0 0 0 } } [ 1 int32_t >n-byte-array ] unit-test
