! Copyright (C) 2022 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: base32hex byte-arrays kernel sequences strings tools.test ;

{ t } [ 256 <iota> >byte-array dup >base32hex base32hex> = ] unit-test

{ B{ } } [ f >base32hex ] unit-test
{ B{ } } [ B{ } >base32hex ] unit-test
{ "00======" } [ "\0" >base32hex "" like ] unit-test
{ "C4======" } [ "a" >base32hex "" like ] unit-test
{ "C5H0====" } [ "ab" >base32hex "" like ] unit-test
{ "C5H66===" } [ "abc" >base32hex "" like ] unit-test
{ "C5H66P0=" } [ "abcd" >base32hex "" like ] unit-test
{ "C5H66P35" } [ "abcde" >base32hex "" like ] unit-test

{ B{ } } [ f base32hex> ] unit-test
{ B{ } } [ B{ } base32hex> ] unit-test
{ "\0" } [ "00======" base32hex> "" like ] unit-test
{ "a" } [ "C4======" base32hex> "" like ] unit-test
{ "ab" } [ "C5H0====" base32hex> "" like ] unit-test
{ "abc" } [ "C5H66===" base32hex> "" like ] unit-test
{ "abcd" } [ "C5H66P0=" base32hex> "" like ] unit-test
{ "abcde" } [ "C5H66P35" base32hex> "" like ] unit-test

{ "" } [ "" >base32hex >string ] unit-test
{ "CO======" } [ "f" >base32hex >string ] unit-test
{ "CPNG====" } [ "fo" >base32hex >string ] unit-test
{ "CPNMU===" } [ "foo" >base32hex >string ] unit-test
{ "CPNMUOG=" } [ "foob" >base32hex >string ] unit-test
{ "CPNMUOJ1" } [ "fooba" >base32hex >string ] unit-test
{ "CPNMUOJ1E8======" } [ "foobar" >base32hex >string ] unit-test

{ "" } [ "" base32hex> >string ] unit-test
{ "f" } [ "CO======" base32hex> >string ] unit-test
{ "fo" } [ "CPNG====" base32hex> >string ] unit-test
{ "foo" } [ "CPNMU===" base32hex> >string ] unit-test
{ "foob" } [ "CPNMUOG=" base32hex> >string ] unit-test
{ "fooba" } [ "CPNMUOJ1" base32hex> >string ] unit-test
{ "foobar" } [ "CPNMUOJ1E8======" base32hex> >string ] unit-test
