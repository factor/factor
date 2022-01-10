USING: binhex binhex.private io.encodings.binary
io.streams.byte-array kernel sequences strings tools.test ;

{ 0x0000 } [ "" crc16-binhex ] unit-test
{ 0x58e5 } [ "A" crc16-binhex ] unit-test
{ 0x31c3 } [ "123456789" crc16-binhex ] unit-test
{ 0xabe3 } [ 256 CHAR: A <string> crc16-binhex ] unit-test

{ B{ 0x41 0x90 0x64 0x42 0x43 0x90 0xff 0x43 0x90 0x2d } } [
    100 CHAR: A <string>
    "B"
    300 CHAR: C <string> 3append
    rle90-encode
] unit-test

{ B{ 0x2B 0x90 0x90 0x90 0x90 0x90 } } [
    B{ 0x2B 0x90 0x00 0x90 0x05 } rle90-decode
] unit-test

{ B{ 0x34 0xe3 0xd0 } } [ "0123" hqx-decode ] unit-test

{ "0123" } [ B{ 0x34 0xe3 0xd0 } hqx-encode >string ] unit-test

{ t } [
    T{ binhex f "test.txt" 0 0 0 B{ 1 2 3 4 } f }
    dup
    binary [ write-binhex ] with-byte-writer
    binary [ read-binhex ] with-byte-reader
    =
] unit-test
