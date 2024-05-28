! Copyright (C) 2006 Matthew Willis and Chris Double.
! See https://factorcode.org/license.txt for BSD license.
USING: destructors io io.encodings.utf8 io.files kernel lists
lists.lazy math sequences tools.test ;

{ { 1 2 3 4 } } [
  { 1 2 3 4 } >list list>array
] unit-test

{ { { 1 4 } { 1 5 } { 2 4 } { 2 5 } { 3 4 } { 3 5 } } } [
  { 1 2 3 } >list { 4 5 } >list 2list lcartesian-product* list>array
] unit-test

{ { { 1 4 } { 1 5 } { 2 4 } { 2 5 } { 3 4 } { 3 5 } } } [
  { 1 2 3 } >list { 4 5 } >list lcartesian-product list>array
] unit-test

{ { 5 6 6 7 7 8 } } [
  { 1 2 3 } >list { 4 5 } >list 2list [ + ] lcartesian-map list>array
] unit-test

{ { 5 6 7 8 } } [
  { 1 2 3 } >list { 4 5 } >list 2list { [ drop odd? ] } [ + ] lcartesian-map* list>array
] unit-test

{ { 4 5 6 } } [
    3 { 1 2 3 } >list [ + ] with lmap-lazy list>array
] unit-test

{ { 1 2 4 8 16 } } [
  5 1 [ 2 * ] lfrom-by ltake list>array
] unit-test

[ [ ] lmap ] must-infer
[ [ ] lmap>array ] must-infer
[ [ drop ] foldr ] must-infer
[ [ drop ] foldl ] must-infer
[ [ drop ] leach ] must-infer
[ lnth ] must-infer

{ { 1 2 3 } } [ { 1 2 3 4 5 } >list [ 2 > ] luntil list>array ] unit-test

{ { 1 2 3 } } [ [ 1 ] [ 2 ] [ 3 ] 3lazy-list list>array ] unit-test

{ } [
    "resource:LICENSE.txt" utf8 <file-reader> [
        llines list>array drop
    ] with-disposal
] unit-test
{ } [
    "resource:LICENSE.txt" utf8 <file-reader> [
        lcontents list>array drop
    ] with-disposal
] unit-test
