! Copyright (C) 2019 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: base32 tools.test ;

{ "16J" } [ 1234 base32> ] unit-test
{ "16JD" } [ 1234 base32-checksum> ] unit-test
{ "0" } [ 0 base32> ] unit-test
{ "00" } [ 0 base32-checksum> ] unit-test
[ -1 base32> ] must-fail
[ 1.0 base32> ] must-fail

{ 1234 } [ "16J" >base32 ] unit-test
{ 1234 } [ "I6J" >base32 ] unit-test
{ 1234 } [ "i6J" >base32 ] unit-test
{ 1234 } [ "16JD" >base32-checksum ] unit-test
{ 1234 } [ "I6JD" >base32-checksum ] unit-test
{ 1234 } [ "i6JD" >base32-checksum ] unit-test
{ 0 } [ "0" >base32 ] unit-test
{ 0 } [ "00" >base32-checksum ] unit-test
