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

{ "16J" } [ 1234 >base32-crockford ] unit-test
{ "16JD" } [ 1234 >base32-crockford-checksum ] unit-test
{ "0" } [ 0 >base32-crockford ] unit-test
{ "00" } [ 0 >base32-crockford-checksum ] unit-test
[ -1 >base32-crockford ] must-fail
[ 1.0 >base32-crockford ] must-fail

{ 1234 } [ "16J" base32-crockford> ] unit-test
{ 1234 } [ "I6J" base32-crockford> ] unit-test
{ 1234 } [ "i6J" base32-crockford> ] unit-test
{ 1234 } [ "16JD" base32-crockford-checksum> ] unit-test
{ 1234 } [ "I6JD" base32-crockford-checksum> ] unit-test
{ 1234 } [ "i6JD" base32-crockford-checksum> ] unit-test
{ 0 } [ "0" base32-crockford> ] unit-test
{ 0 } [ "00" base32-crockford-checksum> ] unit-test
