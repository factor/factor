! Copyright (C) 2021 Your name.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test http2.hpack http2.hpack.private accessors
kernel sequences ;
IN: http2.hpack.tests

! constants are from RFC 7541, appendix C, various sections
CONSTANT: c1  B{ 234 31 154 10 42 }
CONSTANT: c21 B{ 0x40 0x0a 0x63 0x75 0x73 0x74 0x6f 0x6d 0x2d
    0x6b 0x65 0x79 0x0d 0x63 0x75 0x73 0x74 0x6f 0x6d 0x2d
    0x68 0x65 0x61 0x64 0x65 0x72 }
CONSTANT: c22 B{ 0x04 0x0c 0x2f 0x73 0x61 0x6d 0x70 0x6c 0x65
    0x2f 0x70 0x61 0x74 0x68 }
CONSTANT: c23 B{ 0x10 0x08 0x70 0x61 0x73 0x73 0x77 0x6f 0x72
    0x64 0x06 0x73 0x65 0x63 0x72 0x65 0x74 }
CONSTANT: c24 B{ 0x82 }

CONSTANT: c31 B{ 0x82 0x86 0x84 0x41 0x0f 0x77 0x77 0x77 0x2e
    0x65 0x78 0x61 0x6d 0x70 0x6c 0x65 0x2e 0x63 0x6f 0x6d }
CONSTANT: c32 B{ 0x82 0x86 0x84 0xbe 0x58 0x08 0x6e 0x6f 0x2d
    0x63 0x61 0x63 0x68 0x65 }
CONSTANT: c33 B{ 0x82 0x87 0x85 0xbf 0x40 0x0a 0x63 0x75 0x73
    0x74 0x6f 0x6d 0x2d 0x6b 0x65 0x79 0x0c 0x63 0x75 0x73
    0x74 0x6f 0x6d 0x2d 0x76 0x61 0x6c 0x75 0x65 }

CONSTANT: c31h { { ":method" "GET" } { ":scheme" "http" }
    { ":path" "/" } { ":authority" "www.example.com" } }
CONSTANT: c32h { { ":method" "GET" } { ":scheme" "http" }
    { ":path" "/" } { ":authority" "www.example.com" } 
    { "cache-control" "no-cache" } }
CONSTANT: c33h { { ":method" "GET" } { ":scheme" "https" }
    { ":path" "/index.html" } { ":authority" "www.example.com" } 
    { "custom-key" "custom-value" } }

CONSTANT: c51 B{ 0x48 0x03 0x33 0x30 0x32 0x58 0x07 0x70 0x72
0x69 0x76 0x61 0x74 0x65 0x61 0x1d 0x4d 0x6f 0x6e 0x2c 0x20 0x32
0x31 0x20 0x4f 0x63 0x74 0x20 0x32 0x30 0x31 0x33 0x20 0x32
0x30 0x3a 0x31 0x33 0x3a 0x32 0x31 0x20 0x47 0x4d 0x54 0x6e
0x17 0x68 0x74 0x74 0x70 0x73 0x3a 0x2f 0x2f 0x77 0x77 0x77
0x2e 0x65 0x78 0x61 0x6d 0x70 0x6c 0x65 0x2e 0x63 0x6f 0x6d }
CONSTANT: c52 B{ 0x48 0x03 0x33 0x30 0x37 0xc1 0xc0 0xbf }
CONSTANT: c53 B{ 0x88 0xc1 0x61 0x1d 0x4d 0x6f 0x6e 0x2c 0x20
0x32 0x31 0x20 0x4f 0x63 0x74 0x20 0x32 0x30 0x31 0x33 0x20 0x32
0x30 0x3a 0x31 0x33 0x3a 0x32 0x32 0x20 0x47 0x4d 0x54 0xc0
0x5a 0x04 0x67 0x7a 0x69 0x70 0x77 0x38 0x66 0x6f 0x6f 0x3d
0x41 0x53 0x44 0x4a 0x4b 0x48 0x51 0x4b 0x42 0x5a 0x58 0x4f
0x51 0x57 0x45 0x4f 0x50 0x49 0x55 0x41 0x58 0x51 0x57 0x45
0x4f 0x49 0x55 0x3b 0x20 0x6d 0x61 0x78 0x2d 0x61 0x67 0x65
0x3d 0x33 0x36 0x30 0x30 0x3b 0x20 0x76 0x65 0x72 0x73 0x69
0x6f 0x6e 0x3d 0x31 }

CONSTANT: c51h { { ":status" "302" }
    { "cache-control" "private" }
    { "date" "Mon, 21 Oct 2013 20:13:21 GMT" }
    { "location" "https://www.example.com" } }
CONSTANT: c52h { { ":status" "307" }
    { "cache-control" "private" }
    { "date" "Mon, 21 Oct 2013 20:13:21 GMT" }
    { "location" "https://www.example.com" } }
CONSTANT: c53h { { ":status" "200" }
    { "cache-control" "private" }
    { "date" "Mon, 21 Oct 2013 20:13:22 GMT" }
    { "location" "https://www.example.com" }
    { "content-encoding" "gzip" }
    { "set-cookie" "foo=ASDJKHQKBZXOQWEOPIUAXQWEOIU; max-age=3600; version=1" } }


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


! RFC7541 Appendix C.3
{
    { { ":method" "GET" } { ":scheme" "http" }
        { ":path" "/" } { ":authority" "www.example.com" } }
    { { ":method" "GET" } { ":scheme" "http" }
        { ":path" "/" } { ":authority" "www.example.com" } 
        { "cache-control" "no-cache" } }
    { { ":method" "GET" } { ":scheme" "https" }
        { ":path" "/index.html" } { ":authority" "www.example.com" } 
        { "custom-key" "custom-value" } }
    T{ hpack-context f 4096 { { "custom-key" "custom-value" }
                                { "cache-control" "no-cache" }
                                { ":authority" "www.example.com" } } }
}
[ hpack-context new c31 c32 c33 [ hpack-decode swap ] tri@ ] unit-test


! RFC7541 Appendix C.5
{
    {
        { ":status" "302" }
        { "cache-control" "private" }
        { "date" "Mon, 21 Oct 2013 20:13:21 GMT" }
        { "location" "https://www.example.com" }
    }
    {
        { ":status" "307" }
        { "cache-control" "private" }
        { "date" "Mon, 21 Oct 2013 20:13:21 GMT" }
        { "location" "https://www.example.com" }
    }
    {
        { ":status" "200" }
        { "cache-control" "private" }
        { "date" "Mon, 21 Oct 2013 20:13:22 GMT" }
        { "location" "https://www.example.com" }
        { "content-encoding" "gzip" }
        { "set-cookie" "foo=ASDJKHQKBZXOQWEOPIUAXQWEOIU; max-age=3600; version=1" }
    }
    T{ hpack-context f 256 { { "set-cookie" "foo=ASDJKHQKBZXOQWEOPIUAXQWEOIU; max-age=3600; version=1" }
                             { "content-encoding" "gzip" }
                             { "date" "Mon, 21 Oct 2013 20:13:22 GMT" } } }
}
[ hpack-context new 256 >>max-size c51 c52 c53
    [ hpack-decode swap ] tri@ ] unit-test


! encoding can be tested primarily by ensuring the encoding and
! decoding of an object yields the same object (since encoding
! does not have a well defined output other then `decodable').


! integer and string encoding tests
{ B{ 0b00101010 } } [ 0b00100000 10 5 encode-integer ] unit-test
{ B{ 0b01011111 0b10011010 0b00001010 } } [ 0b01000000 1337 5 encode-integer ] unit-test
{ B{ 0b00101010 } } [ 0b00000000 42 8 encode-integer ] unit-test

! assumes no huffman encoding
{ B{ 0x0a 0x63 0x75 0x73 0x74 0x6f 0x6d 0x2d 0x6b 0x65 0x79 } }
[ "custom-key" encode-string ] unit-test


! single header encoding check, mirrors the tests from RFC 7541, Appendix C.2
{ t t { "custom-key" "custom-header" } }
[ hpack-context new { "custom-key" "custom-header" } encode-field 
  hpack-context new swap 0 decode-field 
  [ [ = ] [ swap length = ] 2bi* ] dip ! check contexts are the same and the entire block used for decoding 
] unit-test

{ t t { ":path" "/sample/path" } }
[ hpack-context new { ":path" "/sample/path" } encode-field 
  hpack-context new swap 0 decode-field 
  [ [ = ] [ swap length = ] 2bi* ] dip ! check contexts are the same and the entire block used for decoding 
] unit-test

{ t t { "password" "secret" } }
[ hpack-context new { "password" "secret" } encode-field 
  hpack-context new swap 0 decode-field 
  [ [ = ] [ swap length = ] 2bi* ] dip ! check contexts are the same and the entire block used for decoding 
] unit-test

{ t t { ":method" "GET" } }
[ hpack-context new { ":method" "GET" } encode-field 
  hpack-context new swap 0 decode-field 
  [ [ = ] [ swap length = ] 2bi* ] dip ! check contexts are the same and the entire block used for decoding 
] unit-test


! many header encoding check, using same values from RFC7541 Appendix C.3 and C.5
{
    { { ":method" "GET" } { ":scheme" "http" }
        { ":path" "/" } { ":authority" "www.example.com" } }
    { { ":method" "GET" } { ":scheme" "http" }
        { ":path" "/" } { ":authority" "www.example.com" } 
        { "cache-control" "no-cache" } }
    { { ":method" "GET" } { ":scheme" "https" }
        { ":path" "/index.html" } { ":authority" "www.example.com" } 
        { "custom-key" "custom-value" } }
    t
}
[ hpack-context new c31h c32h c33h [ hpack-encode swap ] tri@ 
  [ [ hpack-context new ] 3dip [ hpack-decode swap ] tri@ ] dip
  = ! check that the encode and decode contexts are identical
] unit-test

{
    {
        { ":status" "302" }
        { "cache-control" "private" }
        { "date" "Mon, 21 Oct 2013 20:13:21 GMT" }
        { "location" "https://www.example.com" }
    }
    {
        { ":status" "307" }
        { "cache-control" "private" }
        { "date" "Mon, 21 Oct 2013 20:13:21 GMT" }
        { "location" "https://www.example.com" }
    }
    {
        { ":status" "200" }
        { "cache-control" "private" }
        { "date" "Mon, 21 Oct 2013 20:13:22 GMT" }
        { "location" "https://www.example.com" }
        { "content-encoding" "gzip" }
        { "set-cookie" "foo=ASDJKHQKBZXOQWEOPIUAXQWEOIU; max-age=3600; version=1" }
    }
    t
}
[ hpack-context new c51h c52h c53h [ hpack-encode swap ] tri@ 
  [ [ hpack-context new ] 3dip [ hpack-decode swap ] tri@ ] dip
  = ! check that the encode and decode contexts are identical
] unit-test

