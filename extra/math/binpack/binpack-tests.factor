! Copyright (C) 2008 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: kernel tools.test math.binpack ;

[ t ] [ { V{ } } { } 1 binpack = ] unit-test

[ t ] [ { { 3 } { 2 1 } } { 1 2 3 } 2 binpack* = ] unit-test

[ t ] [ { { 1000 } { 100 60 30 7 } { 70 60 40 23 3 } } 
        { 100 23 40 60 1000 30 60 07 70 03 } 3 binpack* = ] unit-test


