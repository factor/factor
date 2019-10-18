! Copyright (C) 2006 Matthew Willis and Chris Double.
! See http://factorcode.org/license.txt for BSD license.
!
USING: lazy-lists tools.test kernel math io sequences ;
IN: temporary

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
