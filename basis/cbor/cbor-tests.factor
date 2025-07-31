USING: arrays assocs calendar cbor hex-strings kernel
linked-assocs literals math ranges tools.test urls ;

{
    { 0 "00" }
    { 1 "01" }
    { 10 "0a" }
    { 23 "17" }
    { 24 "1818" }
    { 25 "1819" }
    { 100 "1864" }
    { 1000 "1903e8" }
    { 1000000 "1a000f4240" }
    { 1000000000000 "1b000000e8d4a51000" }
    { 18446744073709551615 "1bffffffffffffffff" }
    { 18446744073709551616 "c249010000000000000000" }
    { -18446744073709551616 "3bffffffffffffffff" }
    { -18446744073709551617 "c349010000000000000000" }
    { -1 "20" }
    { -10 "29" }
    { -100 "3863" }
    { -1000 "3903e7" }
    { 0.0 "f90000" }
    { -0.0 "f98000" }
    { 1.0 "f93c00" }
    { 1.1 "fb3ff199999999999a" }
    { 1.5 "f93e00" }
    { 65504.0 "f97bff" }
    { 100000.0 "fa47c35000" }
    { 3.4028234663852886e+38 "fa7f7fffff" }
    { 1.0e+300 "fb7e37e43c8800759c" }
    ! FIXME { 5.960464477539063e-8 "f90001" }
    { 0.00006103515625 "f90400" }
    { -4.0 "f9c400" }
    { -4.1 "fbc010666666666666" }
    { 1/0. "f97c00" }
    { NAN: 8000000000000 "f97e00" }
    { -1/0. "f9fc00" }
    { 1/0. "fa7f800000" }
    { NAN: 8000000000000 "fa7fc00000" }
    { -1/0. "faff800000" }
    { 1/0. "fb7ff0000000000000" }
    { NAN: 8000000000000 "fb7ff8000000000000" }
    { -1/0. "fbfff0000000000000" }
    { f "f4" }
    { t "f5" }
    { +cbor-nil+ "f6" }
    { +cbor-undefined+ "f7" }
    { T{ cbor-simple f 16 } "f0" }
    { T{ cbor-simple f 24 } "f818" }
    { T{ cbor-simple f 255 } "f8ff" }
    {
        T{ timestamp { year 2013 } { month 3 } { day 21 } { hour 20 } { minute 4 } }
        "c074323031332d30332d32315432303a30343a30305a"
    }
    {
        T{ timestamp { year 2013 } { month 3 } { day 21 } { hour 20 } { minute 4 } }
        "c11a514b67b0"
    }
    {
        T{ timestamp { year 2013 } { month 3 } { day 21 } { hour 20 } { minute 4 } { second 0.5 } }
        "c1fb41d452d9ec200000"
    }
    { T{ cbor-tagged f 23 B{ 1 2 3 4 } } "d74401020304" }
    { T{ cbor-tagged f 24 B{ 0x64 0x49 0x45 0x54 0x46 } } "d818456449455446" }
    { URL" http://www.example.com" "d82076687474703a2f2f7777772e6578616d706c652e636f6d" }
    { B{ } "40" }
    { B{ 1 2 3 4 } "4401020304" }
    { B{ 0xaa 0xbb 0xcc 0xdd 0xee 0xff 0x99 } "5F44aabbccdd43eeff99ff" }
    { "" "60" }
    { "a" "6161" }
    { "IETF" "6449455446" }
    { "\"\\" "62225c" }
    { "\u0000fc" "62c3bc" }
    { "\u006c34" "63e6b0b4" }
    ! FIXME { "\u00d800\u00dd51" "64f0908591" }
    { { } "80" }
    { { 1 2 3 } "83010203" }
    { { 1 { 2 3 } { 4 5 } } "8301820203820405" }
    ${ 25 [1..b] >array "98190102030405060708090a0b0c0d0e0f101112131415161718181819" }
    { LH{ } "a0" }
    { LH{ { 1 2 } { 3 4 } } "a201020304" }
    { LH{ { "a" 1 } { "b" { 2 3 } } } "a26161016162820203" }
    { { "a" LH{ { "b" "c" } } } "826161a161626163" }
    {
        LH{ { "a" "A" } { "b" "B" } { "c" "C" } { "d" "D" } { "e" "E" } }
        "a56161614161626142616361436164614461656145"
    }
    { { 1 { 2 3 } { 4 5 } } "9f018202039f0405ffff" }
    { { 1 { 2 3 } { 4 5 } } "9f01820203820405ff" }
    { { 1 { 2 3 } { 4 5 } } "83018202039f0405ff" }
    { { 1 { 2 3 } { 4 5 } } "83019f0203ff820405" }
    ${ 25 [1..b] >array "9f0102030405060708090a0b0c0d0e0f101112131415161718181819ff" }
    { LH{ { "a" 1 } { "b" { 2 3 } } } "bf61610161629f0203ffff" }
    { { "a" LH{ { "b" "c" } } } "826161bf61626163ff" }
    { LH{ { "Fun" t } { "Amt" -2 } } "bf6346756ef563416d7421ff" }
} [| value hex-string |

    hex-string hex-string>bytes :> bytes

    value fp-nan? [
        { t t } [
            bytes cbor> [ fp-nan? ] [ fp-nan-payload ] bi
            value fp-nan-payload =
        ] unit-test
    ] [
        { value } [ bytes cbor> ] unit-test
    ] if

] assoc-each
