! Copyright (C) 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: random random.dummy tools.test ;
IN: random.dummy.tests

{ 10 } [ 10 <random-dummy> random-32* ] unit-test
{ 100 } [ 10 <random-dummy> 100 seed-random random-32* ] unit-test
