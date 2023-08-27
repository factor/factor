! Copyright (C) 2022 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: math stack-as-data tools.test ;
IN: stack-as-data.tests

{ 10 20 30 50 40 } [ 10 20 30 40 50  0 1 stack-exchange ] unit-test
{ 20 10 30 40 50 } [ 10 20 30 40 50  4 3 stack-exchange ] unit-test
{ 20 10 30 40 50 } [ 10 20 30 40 50  3 4 stack-exchange ] unit-test
{ 10 20 30 40 50 } [ 10 20 30 40 50  0 0 stack-exchange ] unit-test

! { V{ 6 8 } }
! [
!     5 6 7 8
!     4 [ even? ] stack-filter
! ] unit-test

{ 25 36 49 64 }
[
    5 6 7 8
    4 [ sq ] stack-map
] unit-test

