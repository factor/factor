! Copyright (C) 2021 Your name.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test http2.hpack hpack.private ;
IN: http2.hpack.tests

! tests come from RFC 7541, Appendix C
{ BV{ 234 31 154 10 42 } 1   10 } [ BV{ 234 31 154 10 42 } 0 5 decode-integer ] unit-test
{ BV{ 234 31 154 10 42 } 4 1337 } [ BV{ 234 31 154 10 42 } 1 5 decode-integer ] unit-test
{ BV{ 234 31 154 10 42 } 5   42 } [ BV{ 234 31 154 10 42 } 4 8 decode-integer ] unit-test

{ BV{ 0x0a 0x63 0x75 0x73 0x74 0x6f 0x6d 0x2d 0x6b 0x65 0x79 }
11 "custom-key" } [ BV{ 0x0a 0x63 0x75 0x73 0x74 0x6f 0x6d 0x2d
0x6b 0x65 0x79 } 0 decode-string ] unit-test

