! Copyright (C) 2022 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: base32hex byte-arrays kernel sequences tools.test ;

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
