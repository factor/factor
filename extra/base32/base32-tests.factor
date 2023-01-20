! Copyright (C) 2019 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: base32 byte-arrays kernel sequences tools.test ;

{ t } [ 256 <iota> >byte-array dup >base32 base32> = ] unit-test

{ B{ } } [ f >base32 ] unit-test
{ B{ } } [ B{ } >base32 ] unit-test
{ "AA======" } [ "\0" >base32 "" like ] unit-test
{ "ME======" } [ "a" >base32 "" like ] unit-test
{ "MFRA====" } [ "ab" >base32 "" like ] unit-test
{ "MFRGG===" } [ "abc" >base32 "" like ] unit-test
{ "MFRGGZA=" } [ "abcd" >base32 "" like ] unit-test
{ "MFRGGZDF" } [ "abcde" >base32 "" like ] unit-test

{ B{ } } [ f base32> ] unit-test
{ B{ } } [ B{ } base32> ] unit-test
{ "\0" } [ "AA======" base32> "" like ] unit-test
{ "a" } [ "ME======" base32> "" like ] unit-test
{ "ab" } [ "MFRA====" base32> "" like ] unit-test
{ "abc" } [ "MFRGG===" base32> "" like ] unit-test
{ "abcd" } [ "MFRGGZA=" base32> "" like ] unit-test
{ "abcde" } [ "MFRGGZDF" base32> "" like ] unit-test
