! Copyright (C) 2021 Your name.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test http2.hpack http2.hpack.private accessors kernel ;
IN: http2.hpack.tests

CONSTANT: c1  B{ 234 31 154 10 42 }
CONSTANT: c21 B{ 0x40 0x0a 0x63 0x75 0x73 0x74 0x6f 0x6d 0x2d
    0x6b 0x65 0x79 0x0d 0x63 0x75 0x73 0x74 0x6f 0x6d 0x2d
    0x68 0x65 0x61 0x64 0x65 0x72 }
CONSTANT: c22 B{ 0x04 0x0c 0x2f 0x73 0x61 0x6d 0x70 0x6c 0x65
    0x2f 0x70 0x61 0x74 0x68 }
CONSTANT: c23 B{ 0x10 0x08 0x70 0x61 0x73 0x73 0x77 0x6f 0x72
    0x64 0x06 0x73 0x65 0x63 0x72 0x65 0x74 }
CONSTANT: c24 B{ 0x82 }

! tests come from RFC 7541, Appendix C

! RFC7541 Appendex C.1
{ 1   10 } [ c1 0 5 decode-integer nipd ] unit-test
{ 4 1337 } [ c1 1 5 decode-integer nipd ] unit-test
{ 5   42 } [ c1 4 8 decode-integer nipd ] unit-test

! RFC7541 Appendix C.2.1 subset
{ 12 "custom-key" }
[ c21 1 decode-string nipd ] unit-test

! RFC7541 Appendix C.2.1
{ T{ hpack-context f 4096 { { "custom-key" "custom-header" } } } 
   26 { "custom-key" "custom-header" } }
[ hpack-context new c21 0 decode-field nipd ] unit-test

! RFC7541 Appendix C.2.2
{ T{ hpack-context f 4096 { } }  14 { ":path" "/sample/path" } }
[ hpack-context new c22 0 decode-field nipd ] unit-test

! RFC7541 Appendix C.2.3
{ T{ hpack-context f 4096 { } } 17 { "password" "secret" } }
[ hpack-context new c23 0 decode-field nipd ] unit-test

! RFC7541 Appendix C.2.4
{ T{ hpack-context f 4096 { } } 1 { ":method" "GET" } }
[ hpack-context new c24 0 decode-field nipd ] unit-test

