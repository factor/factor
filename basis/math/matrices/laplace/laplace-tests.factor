! Copyright (C) 2013 Your name.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test determinant kernel ;
IN: math.matrices.laplace.tests

[ t ] [ 0 0 0 ij-to-n 0 = ] unit-test
[ t ] [ 1 0 1 ij-to-n 1 = ] unit-test
[ t ] [ 2 0 0 ij-to-n 0 = ] unit-test
[ t ] [ 2 0 1 ij-to-n 1 = ] unit-test
[ t ] [ 2 1 0 ij-to-n 2 = ] unit-test
[ t ] [ 2 1 1 ij-to-n 3 = ] unit-test
[ t ] [ 3 0 0 ij-to-n 0 = ] unit-test
[ t ] [ 3 0 1 ij-to-n 1 = ] unit-test
[ t ] [ 3 0 2 ij-to-n 2 = ] unit-test
[ t ] [ 3 1 0 ij-to-n 3 = ] unit-test
[ t ] [ 3 1 1 ij-to-n 4 = ] unit-test
[ t ] [ 3 1 2 ij-to-n 5 = ] unit-test
[ t ] [ 3 2 0 ij-to-n 6 = ] unit-test
[ t ] [ 3 2 1 ij-to-n 7 = ] unit-test
[ t ] [ 3 2 2 ij-to-n 8 = ] unit-test

[ t ] [ { { 1 2 } { 3 4 } } det -2 = ] unit-test
[ t ] [ { { 1 2 3 } { 4 5 6 } { 7 8 9 } } det 0 = ] unit-test
[ t ] [ { { 40 39 38 37 } { 1 1 1 831 } 
          { 22 22 1110 299 } { 13 14 15 17 } } 
          det -47860032 = ] unit-test

