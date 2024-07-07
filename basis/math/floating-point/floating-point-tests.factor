! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: tools.test math.floating-point kernel
math.constants fry sequences math random ;
IN: math.floating-point.tests

{ t } [ pi >double< >double pi = ] unit-test
{ t } [ -1.0 >double< >double -1.0 = ] unit-test

{ t } [ 1/0. infinity? ] unit-test
{ t } [ -1/0. infinity? ] unit-test
{ f } [ 0/0. infinity? ] unit-test
{ f } [ 10. infinity? ] unit-test
{ f } [ -10. infinity? ] unit-test
{ f } [ 0. infinity? ] unit-test

{ 0 } [ 0.0 double>ratio ] unit-test
{ 1 } [ 1.0 double>ratio ] unit-test
{ 1/2 } [ 0.5 double>ratio ] unit-test
{ 3/4 } [ 0.75 double>ratio ] unit-test
{ 12+1/2 } [ 12.5 double>ratio ] unit-test
{ -12-1/2 } [ -12.5 double>ratio ] unit-test
{ 3+39854788871587/281474976710656 } [ pi double>ratio ] unit-test

: roundtrip ( n -- )
    [ '[ _ ] ] keep '[ _ double>ratio >float ] unit-test ;

{ 1 12 123 1234 } [ bits>double roundtrip ] each

100 [ -10.0 10.0 uniform-random roundtrip ] times
