USING: checksums checksums.khash endian tools.test ;

{ 0x1a7c42225eeae57c } [
    0x1234567890ABCDEF 8 >le <khash64> checksum-bytes
] unit-test

{ 0xec1cdb4b1aeb20d7 } [
    0x90ABCDEF12345678 8 >le <khash64> checksum-bytes
] unit-test
