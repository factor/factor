! Copyright (C) 2019 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: base32 byte-arrays kernel sequences strings tools.test ;

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

{ "" } [ "" >base32 >string ] unit-test
{ "MY======" } [ "f" >base32 >string ] unit-test
{ "MZXQ====" } [ "fo" >base32 >string ] unit-test
{ "MZXW6===" } [ "foo" >base32 >string ] unit-test
{ "MZXW6YQ=" } [ "foob" >base32 >string ] unit-test
{ "MZXW6YTB" } [ "fooba" >base32 >string ] unit-test
{ "MZXW6YTBOI======" } [ "foobar" >base32 >string ] unit-test

{ "" } [ "" base32> >string ] unit-test
{ "f" } [ "MY======" base32> >string ] unit-test
{ "fo" } [ "MZXQ====" base32> >string ] unit-test
{ "foo" } [ "MZXW6===" base32> >string ] unit-test
{ "foob" } [ "MZXW6YQ=" base32> >string ] unit-test
{ "fooba" } [ "MZXW6YTB" base32> >string ] unit-test
{ "foobar" } [ "MZXW6YTBOI======" base32> >string ] unit-test
