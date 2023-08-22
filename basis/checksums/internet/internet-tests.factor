! Copyright (C) 2010 John Benediktsson
! See https://factorcode.org/license.txt for BSD license
USING: checksums checksums.internet tools.test ;

{ B{ 255 255 } } [ { } internet checksum-bytes ] unit-test
{ B{ 254 255 } } [ { 1 } internet checksum-bytes ] unit-test
{ B{ 254 253 } } [ { 1 2 } internet checksum-bytes ] unit-test
{ B{ 251 253 } } [ { 1 2 3 } internet checksum-bytes ] unit-test

{ B{ 34 13 } } [
    B{
        0x00 0x01
        0xf2 0x03
        0xf4 0xf5
        0xf6 0xf7
    } internet checksum-bytes
] unit-test
