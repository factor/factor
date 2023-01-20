! Copyright (C) 2010 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: cuda.devices tools.test ;
IN: cuda.devices.tests

{ 1  5 100 } [  5 20 100 10 (distribute-jobs) ] unit-test
{ 2  5 100 } [ 10 20 100 10 (distribute-jobs) ] unit-test
{ 2  5 100 } [ 10 20 200  5 (distribute-jobs) ] unit-test
{ 2  5 100 } [ 10 20 300  6 (distribute-jobs) ] unit-test
{ 2  6 120 } [ 11 20 300  6 (distribute-jobs) ] unit-test
{ 1 10 200 } [ 10 20 200 10 (distribute-jobs) ] unit-test
{ 1 10   0 } [ 10  0 200 10 (distribute-jobs) ] unit-test
{ 2  5   0 } [ 10  0 200  9 (distribute-jobs) ] unit-test
