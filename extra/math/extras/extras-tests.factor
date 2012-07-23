! Copyright (C) 2012 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: math.extras math.ranges tools.test ;

IN: math.extras.test

{ -1 } [ -1 7 jacobi ] unit-test
{ 0 } [ 3 3 jacobi ] unit-test
{ -1 } [ 127 703 jacobi ] unit-test
{ 1 } [ -4 197 jacobi ] unit-test

{ { 2 3 4 5 6 7 8 9 } } [ 10 [1,b] 3 moving-average ] unit-test
{ { 1+1/2 2+1/2 3+1/2 4+1/2 5+1/2 6+1/2 7+1/2 8+1/2 9+1/2 } }
[ 10 [1,b] 2 moving-average ] unit-test

{ { 1 1+1/2 2+1/4 3+1/8 4+1/16 5+1/32 } }
[ 6 [1,b] 1/2 exponential-moving-average ] unit-test
{ { 1 3 3 5 5 7 7 9 9 11 } }
[ 10 [1,b] 2 exponential-moving-average ] unit-test

{ { 2 5 5 4 3 } } [ { 1 2 5 6 1 4 3 } 3 moving-median ] unit-test

{ { } } [ { 0 0 } nonzero ] unit-test
{ { 1 2 3 } } [ { 0 1 0 2 0 3 0 } nonzero ] unit-test
