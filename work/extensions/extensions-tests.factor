! Copyright (C) 2013 PolyMicro Systems.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test extensions ;
IN: extensions.tests

[ { { 1 "one" } { 3 "three" }  { 2 "two" } } ] [ { { 1 "one" } { 2 "two" } { 1 "one"} { 2 "two" } { 3 "three" } } [ second ] unique-filter ] unit-test
