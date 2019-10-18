! Copyright (C) 2007 Robbert van Dalen.
! See http://factorcode.org/license.txt for BSD license.

USING: kernel sequences isequences.interface isequences.base isequences.ops tools.test strings ;
IN: temporary

! strict isequences (++)
!
{ 4 } [ 4 i-length ] unit-test
{ 4 } [ { 1 2 3 4 } i-length ] unit-test
{ -4 } [ 4 -- i-length ] unit-test
{ -4 } [ { 1 2 3 4 } -- i-length ] unit-test

{ 4 } [ { 1 2 3 } { 4 5 6 } ++ 3 i-at ] unit-test
{ { 3 2 1 } } [ { 1 2 3 } -- to-sequence ] unit-test
{ 0 } [ 100 30 i-at ] unit-test
{ 2 } [ { 1 2 3 4 } 1 i-at ] unit-test
{ 2 } [ { 1 2 3 4 } -- -1 i-at ] unit-test

{ 6 } [ 10 4 -- ++ ] unit-test 
{ { 1 2 3 4 5 6 } }  [ { 1 2 3 } { 4 5 6 } ++ to-sequence ] unit-test
{ { 1 2 3 0 0 0 } }  [ { 1 2 3 } 3 ++ to-sequence ] unit-test
{ { 0 1 2 3 4 5 6 7 8 9 } }  [ 10 [ <i> ] map unclip [ ++ ] reduce to-sequence ] unit-test
{ { 0 1 2 3 } }  [ { 0 1 2 3 4 5 } 2 -- ++ to-sequence ] unit-test 
{ { 3 2 1 } } [ { 1 2 3 4 5 } -- 2 ++ to-sequence ] unit-test
{ { 0 1 2 3 } } [ { 0 1 2 3 4 5 6 } [ 7 8 9 ] -- ++ to-sequence ] unit-test
{ { 6 5 4 3 2 1 } } [ { 1 2 3 } -- { 4 5 6 } -- ++ to-sequence ] unit-test
{ { 0 1 } }  [ 100000 [ <i> ] map unclip [ ++ ] reduce -99998 ++ to-sequence ] unit-test
{ { } } [ { 1 2 3 } { 4 5 6 } -- ++ to-sequence ] unit-test


! (Lazy) Enchilada operators ( ** || `` ~~ :: // ## )
!
{ { 3 2 1 } } [ { 1 2 3 } `` to-sequence ] unit-test
{ { 1 2 3 } } [ { 1 2 3 } `` -- to-sequence ] unit-test
{ { 1 1 2 2 3 3 } { 4 5 4 5 4 5 } } [ { 1 2 3 } { 4 5 } ** [ to-sequence ] 2apply ] unit-test
{ { 3 3 2 2 1 1 } { 4 5 4 5 4 5 } } [ { 1 2 3 } -- { 4 5 } ** [ to-sequence ] 2apply ] unit-test
{ { { 1 3 } { 2 4 } } } [ { { 1 } { 2 } } { { 3 } { 4 } } || to-sequence [ to-sequence ] map ] unit-test
{ { { 1 4 } { 2 3 } } } [ { { 1 } { 2 } } { { 3 } { 4 } } -- || to-sequence [ to-sequence ] map ] unit-test


{ 0 } [ 2 ~~ -2 4 ~~ ++ :: || dup ## :: swap :: ## :: swap ++ to-sequence 4 ~~ i-cmp ] unit-test
{ { { 1 4 } { 2 5 } { 3 } } } [ { { 1 } { 2 } { 3 } } { { 4 } { 5 } } || to-sequence [ to-sequence ] map ] unit-test
{ 0 } [ 4 ~~ to-sequence 4 [ <i> <i> ] map unclip [ ++ ] reduce i-cmp ] unit-test
{ { 1 1 1 1 2 2 2 3 3 4 } { 1 1 } }  [ { 1 1 2 1 } { 2 3 2 4 3 1 } << [ to-sequence ] 2apply ] unit-test

{ { 0 1 2 "a" 3 4 5 "b" 6 7 8 "c" 9 10 11 "d" } } [ { 0 1 2 3 4 5 6 7 8 9 10 11 } 3 swap ** nip 3 // drop { "a" "b" "c" "d" } ++ 4 swap ** nip 4 // drop to-sequence ] unit-test
