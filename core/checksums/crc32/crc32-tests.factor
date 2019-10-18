USING: checksums checksums.crc32 kernel math tools.test namespaces ;

[ B{ 0 0 0 0 } ] [ "" crc32 checksum-bytes ] unit-test

[ B{ HEX: cb HEX: f4 HEX: 39 HEX: 26 } ] [ "123456789" crc32 checksum-bytes ] unit-test

