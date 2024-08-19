! Copyright (C) 2024 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: base45 byte-arrays kernel sequences strings tools.test ;

{ t } [ 256 <iota> >byte-array dup >base45 base45> = ] unit-test

{ B{ } } [ f >base45 ] unit-test
{ B{ } } [ B{ } >base45 ] unit-test
{ "BB8" } [ "AB" >base45 >string ] unit-test
{ "UJCLQE7W581" } [ "base-45" >base45 >string ] unit-test
{ "%69 VD92EX0" } [ "Hello!!" >base45 >string ] unit-test

{ B{ } } [ f base45> ] unit-test
{ B{ } } [ B{ } base45> ] unit-test
{ "ietf!" } [ "QED8WEX0" base45> >string ] unit-test
