USING: checksums checksums.crc32 kernel math tools.test namespaces ;

{ B{ 0 0 0 0 } } [ "" crc32 checksum-bytes ] unit-test

{ B{ 0xcb 0xf4 0x39 0x26 } } [ "123456789" crc32 checksum-bytes ] unit-test
