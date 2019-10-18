! Copyright (C) 2007 Robbert van Dalen.
! See http://factorcode.org/license.txt for BSD license.

USING: kernel sequences isequences lazy-isequences test errors strings ;
IN: temporary

! strict isequences (++)
!
{ 4 } [ 4 ## ] unit-test
{ 4 } [ { 1 2 3 4 } ## ] unit-test
{ -4 } [ 4 -- ## ] unit-test
{ -4 } [ { 1 2 3 4 } -- ## ] unit-test
{ 4 } [ { 1 2 3 } { 4 5 6 } ++ 3 @@ ] unit-test
{ { 3 2 1 } } [ { 1 2 3 } -- to-sequence ] unit-test
{ [ ] } [ 100 30 @@ ] unit-test
{ 2 } [ { 1 2 3 4 } 1 @@ ] unit-test
{ 2 } [ { 1 2 3 4 } -- -1 @@ ] unit-test
{ 6 } [ 10 4 -- ++ ] unit-test 
{ { 1 2 3 4 5 6 } }  [ { 1 2 3 } { 4 5 6 } ++ to-sequence ] unit-test
{ { 1 2 3 [ ] [ ] [ ] } }  [ { 1 2 3 } 3 ++ to-sequence ] unit-test
{ { 0 1 2 3 4 5 6 7 8 9 } }  [ 10 [ <i> ] map unclip [ ++ ] reduce to-sequence ] unit-test
{ { 0 1 2 3 } }  [ { 0 1 2 3 4 5 } 2 -- ++ to-sequence ] unit-test 
{ { 3 2 1 } } [ { 1 2 3 4 5 } -- 2 ++ to-sequence ] unit-test
{ { 0 1 2 3 } } [ { 0 1 2 3 4 5 6 } [ 7 8 9 ] -- ++ to-sequence ] unit-test
{ { 6 5 4 3 2 1 } } [ { 1 2 3 } -- { 4 5 6 } -- ++ to-sequence ] unit-test
{ { 0 1 } }  [ 100000 [ <i> ] map unclip [ ++ ] reduce -99998 ++ to-sequence ] unit-test
{ { } } [ { 1 2 3 } { 4 5 6 } -- ++ to-sequence ] unit-test


! (cached) lazy isequences (** || ``)
!
{ { 3 2 1 } } [ { 1 2 3 } `` to-sequence ] unit-test
{ { 1 2 3 } } [ { 1 2 3 } `` -- to-sequence ] unit-test
{ { 1 1 2 2 3 3 } { 4 5 4 5 4 5 } } [ { 1 2 3 } { 4 5 } ** [ to-sequence ] 2apply ] unit-test
{ { 3 3 2 2 1 1 } { 4 5 4 5 4 5 } } [ { 1 2 3 } -- { 4 5 } ** [ to-sequence ] 2apply ] unit-test
{ { { 1 3 } { 2 4 } } } [ { { 1 } { 2 } } { { 3 } { 4 } } || to-sequence [ to-sequence ] map ] unit-test
{ { { 1 4 } { 2 3 } } } [ { { 1 } { 2 } } { { 3 } { 4 } } -- || to-sequence [ to-sequence ] map ] unit-test

{ { { 1 4 } { 2 5 } { 3 } } } [ { { 1 } { 2 } { 3 } } { { 4 } { 5 } } || to-sequence [ to-sequence ] map ] unit-test

