! Copyright (C) 2010 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: checksums checksums.internet tools.test ;

IN: checksums

[ B{ 255 255 } ] [ { } internet checksum-bytes ] unit-test
[ B{ 254 255 } ] [ { 1 } internet checksum-bytes ] unit-test
[ B{ 254 253 } ] [ { 1 2 } internet checksum-bytes ] unit-test
[ B{ 251 253 } ] [ { 1 2 3 } internet checksum-bytes ] unit-test

: test-data ( -- bytes )
    B{
        HEX: 00 HEX: 01
        HEX: f2 HEX: 03
        HEX: f4 HEX: f5
        HEX: f6 HEX: f7
    } ;

[ B{ 34 13 } ] [ test-data internet checksum-bytes ] unit-test

