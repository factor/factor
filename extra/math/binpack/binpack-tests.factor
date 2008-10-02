! Copyright (C) 2008 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: kernel tools.test ;

[ t ] [ { { 3 } { 2 1 } } { 1 2 3 } 2 binpack-numbers = ] unit-test

[ t ] [ { { 1000 } { 100 30 } { 70 40 23 } { 60 60 7 3 } } 
        { 100 23 40 60 1000 30 60 07 70 03 } 3 binpack-numbers = ] unit-test


