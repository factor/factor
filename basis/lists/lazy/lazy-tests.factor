! Copyright (C) 2006 Matthew Willis and Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: io io.encodings.utf8 io.files kernel lists lists.lazy
math sequences tools.test ;
IN: lists.lazy.tests

[ { 1 2 3 4 } ] [
  { 1 2 3 4 } >list list>array
] unit-test

[ { { 1 4 } { 1 5 } { 2 4 } { 2 5 } { 3 4 } { 3 5 } } ] [
  { 1 2 3 } >list { 4 5 } >list 2list lcartesian-product* list>array
] unit-test

[ { { 1 4 } { 1 5 } { 2 4 } { 2 5 } { 3 4 } { 3 5 } } ] [
  { 1 2 3 } >list { 4 5 } >list lcartesian-product list>array
] unit-test

[ { 5 6 6 7 7 8 } ] [ 
  { 1 2 3 } >list { 4 5 } >list 2list [ first2 + ] lcomp list>array
] unit-test

[ { 5 6 7 8 } ] [ 
  { 1 2 3 } >list { 4 5 } >list 2list { [ first odd? ] } [ first2 + ] lcomp* list>array
] unit-test

[ { 4 5 6 } ] [ 
    3 { 1 2 3 } >list [ + ] with lazy-map list>array
] unit-test

[ [ ] lmap ] must-infer
[ [ ] lmap>array ] must-infer
[ [ drop ] foldr ] must-infer
[ [ drop ] foldl ] must-infer
[ [ drop ] leach ] must-infer
[ lnth ] must-infer

[ { 1 2 3 } ] [ { 1 2 3 4 5 } >list [ 2 > ] luntil list>array ] unit-test

[ ] [ "resource:license.txt" utf8 <file-reader> llines list>array drop ] unit-test
[ ] [ "resource:license.txt" utf8 <file-reader> lcontents list>array drop ] unit-test
