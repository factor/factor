USING: checksums checksums.crc32 kernel tools.test ;

{ B{ 0 0 0 0 } } [ "" crc32 checksum-bytes ] unit-test

{ B{ 0xcb 0xf4 0x39 0x26 } } [ "123456789" crc32 checksum-bytes ] unit-test

{ t } [
    "resource:LICENSE.txt" crc32
    [ [ swap add-checksum-file get-checksum ] with-checksum-state ]
    [ checksum-file ] 2bi =
] unit-test
