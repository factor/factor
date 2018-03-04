
USING: byte-arrays checksums checksums.metrohash tools.test ;

{ 17099979927131455419 } [
    "abc" T{ metrohash-64 { seed 0 } } checksum-bytes
] unit-test

{ 5688461416820429545 } [
    "abc" T{ metrohash-64 { seed 1234 } } checksum-bytes
] unit-test

{ 1767508563557181619 } [
    "abcdefghijklmnopqrstuvwxyz"
    T{ metrohash-64 { seed 0 } } checksum-bytes
] unit-test

{ 2460573209396975646 } [
    "abcdefghijklmnopqrstuvwxyz"
    T{ metrohash-64 { seed 1234 } } checksum-bytes
] unit-test

{ 878430475465696418 } [
    "this is a really long sentence that needs to be hashed"
    T{ metrohash-64 { seed 0 } } checksum-bytes
] unit-test

{ 14883773106412686490 } [
    "this is a really long sentence that needs to be hashed"
    T{ metrohash-64 { seed 1234 } } checksum-bytes
] unit-test

{ 14883773106412686490 } [
    "this is a really long sentence that needs to be hashed"
    >byte-array T{ metrohash-64 { seed 1234 } } checksum-bytes
] unit-test

{ 14883773106412686490 } [
    T{ metrohash-64 { seed 1234 } } [
        "this is a really " add-checksum-bytes
        "long sentence that " add-checksum-bytes
        "needs to be hashed" add-checksum-bytes
        get-checksum
    ] with-checksum-state
] unit-test

{ 182995299641628952910564950850867298725 } [
    "abc" T{ metrohash-128 { seed 0 } } checksum-bytes
] unit-test

{ 61180998041120637609836805276498424729 } [
    "abc" T{ metrohash-128 { seed 1234 } } checksum-bytes
] unit-test

{ 34499071879213198976518413085708640177 } [
    "abcdefghijklmnopqrstuvwxyz"
    T{ metrohash-128 { seed 0 } } checksum-bytes
] unit-test

{ 179174851912813597938406577526685531497 } [
    "abcdefghijklmnopqrstuvwxyz"
    T{ metrohash-128 { seed 1234 } } checksum-bytes
] unit-test

{ 212255213697664751676685499681764114896 } [
    "this is a really long sentence that needs to be hashed"
    T{ metrohash-128 { seed 0 } } checksum-bytes
] unit-test

{ 182531630340317658385091745884975528732 } [
    "this is a really long sentence that needs to be hashed"
    T{ metrohash-128 { seed 1234 } } checksum-bytes
] unit-test

{ 182531630340317658385091745884975528732 } [
    "this is a really long sentence that needs to be hashed"
    >byte-array T{ metrohash-128 { seed 1234 } } checksum-bytes
] unit-test

{ 182531630340317658385091745884975528732 } [
    T{ metrohash-128 { seed 1234 } } [
        "this is a really " add-checksum-bytes
        "long sentence that " add-checksum-bytes
        "needs to be hashed" add-checksum-bytes
        get-checksum
    ] with-checksum-state
] unit-test
