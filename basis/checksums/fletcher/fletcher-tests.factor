USING: checksums checksums.fletcher kernel sequences tools.test ;

{
    { 51440 3948201259 14034561336514601929 }
} [
    "abcde" { fletcher-16 fletcher-32 fletcher-64 }
    [ checksum-bytes ] with map
] unit-test
