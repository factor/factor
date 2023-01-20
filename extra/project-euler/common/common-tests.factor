! Copyright (C) 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: tools.test project-euler.common ;

{ 4 } [ -1000 number-length ] unit-test
{ 3 } [ -999 number-length ] unit-test
{ 3 } [ -100 number-length ] unit-test
{ 2 } [ -99 number-length ] unit-test
{ 1 } [ -9 number-length ] unit-test
{ 1 } [ -1 number-length ] unit-test
{ 1 } [ 0 number-length ] unit-test
{ 1 } [ 9 number-length ] unit-test
{ 2 } [ 99 number-length ] unit-test
{ 3 } [ 100 number-length ] unit-test
{ 3 } [ 999 number-length ] unit-test
{ 4 } [ 1000 number-length ] unit-test
