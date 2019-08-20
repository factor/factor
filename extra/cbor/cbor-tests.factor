USING: arrays cbor literals math math.parser math.ranges
tools.test ;

{ 500 } [ B{ 0b000,11001 0x01 0xf4 } cbor> ] unit-test

{ -500 } [ B{ 0b001,11001 0x01 0xf3 } cbor> ] unit-test

{ B{ 0xaa 0xbb 0xcc 0xdd 0xee 0xff 0x99 } } [
    B{ 0x5F 0x44 0xaa 0xbb 0xcc 0xdd 0x43 0xee 0xff 0x99 0xff } cbor>
] unit-test

{ 0 } [ B{ 0x00 } cbor> ] unit-test
{ 1 } [ B{ 0x01 } cbor> ] unit-test
{ 10 } [ B{ 0x0a } cbor> ] unit-test
{ 23 } [ B{ 0x17 } cbor> ] unit-test
{ 24 } [ B{ 0x18 0x18 } cbor> ] unit-test
{ 25 } [ B{ 0x18 0x19 } cbor> ] unit-test
{ 100 } [ B{ 0x18 0x64 } cbor> ] unit-test
{ 1000 } [ B{ 0x19 0x03 0xe8 } cbor> ] unit-test
{ 1000000 } [ B{ 0x1a 0x00 0x0f 0x42 0x40 } cbor> ] unit-test
{ 1000000000000 } [ B{ 0x1b 0x00 0x00 0x00 0xe8 0xd4 0xa5 0x10 0x00 } cbor> ] unit-test
{ 18446744073709551615 } [ B{ 0x1b 0xff 0xff 0xff 0xff 0xff 0xff 0xff 0xff } cbor> ] unit-test
! TODO { 18446744073709551616 } [ B{ 0xc2 0x49 0x01 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 } cbor> ] unit-test
{ -18446744073709551616 } [ B{ 0x3b 0xff 0xff 0xff 0xff 0xff 0xff 0xff 0xff } cbor> ] unit-test
! TODO { -18446744073709551617 } [ B{ 0xc3 0x49 0x01 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 } cbor> ] unit-test
{ -1 } [ B{ 0x20 } cbor> ] unit-test
{ -10 } [ B{ 0x29 } cbor> ] unit-test
{ -100 } [ B{ 0x38 0x63 } cbor> ] unit-test
{ -1000 } [ B{ 0x39 0x03 0xe7 } cbor> ] unit-test
{ 0.0 } [ B{ 0xf9 0x00 0x00 } cbor> ] unit-test
{ -0.0 } [ B{ 0xf9 0x80 0x00 } cbor> ] unit-test
{ 1.0 } [ B{ 0xf9 0x3c 0x00 } cbor> ] unit-test
! FIXME { 1.1 } [ B{ 0xfb 0x3f 0xf1 0x99 0x99 0x99 0x99 0x9 0x99a } cbor> ] unit-test
{ 1.5 } [ B{ 0xf9 0x3e 0x00 } cbor> ] unit-test
{ 65504.0 } [ B{ 0xf9 0x7b 0xff } cbor> ] unit-test
{ 100000.0 } [ B{ 0xfa 0x47 0xc3 0x50 0x00 } cbor> ] unit-test
{ 3.4028234663852886e+38 } [ B{ 0xfa 0x7f 0x7f 0xff 0xff } cbor> ] unit-test
{ 1.0e+300 } [ B{ 0xfb 0x7e 0x37 0xe4 0x3c 0x88 0x00 0x75 0x9c } cbor> ] unit-test
! FIXME { 5.960464477539063e-8 } [ B{ 0xf9 0x00 0x01 } cbor> ] unit-test
{ 0.00006103515625 } [ B{ 0xf9 0x04 0x00 } cbor> ] unit-test
{ -4.0 } [ B{ 0xf9 0xc4 0x00 } cbor> ] unit-test
{ -4.1 } [ B{ 0xfb 0xc0 0x10 0x66 0x66 0x66 0x66 0x66 0x66 } cbor> ] unit-test
{ 1/0. } [ B{ 0xf9 0x7c 0x00 } cbor> ] unit-test
{ t } [ B{ 0xf9 0x7e 0x00 } cbor> fp-nan? ] unit-test
{ -1/0. } [ B{ 0xf9 0xfc 0x00 } cbor> ] unit-test
{ 1/0. } [ B{ 0xfa 0x7f 0x80 0x00 0x00 } cbor> ] unit-test
{ t } [ B{ 0xfa 0x7f 0xc0 0x00 0x00 } cbor> fp-nan? ] unit-test
{ -1/0. } [ B{ 0xfa 0xff 0x80 0x00 0x00 } cbor> ] unit-test
{ 1/0. } [ B{ 0xfb 0x7f 0xf0 0x00 0x00 0x00 0x00 0x00 0x00 } cbor> ] unit-test
{ t } [ B{ 0xfb 0x7f 0xf8 0x00 0x00 0x00 0x00 0x00 0x00 } cbor> fp-nan? ] unit-test
{ -1/0. } [ B{ 0xfb 0xff 0xf0 0x00 0x00 0x00 0x00 0x00 0x00 } cbor> ] unit-test
{ f } [ B{ 0xf4 } cbor> ] unit-test
{ t } [ B{ 0xf5 } cbor> ] unit-test
{ +cbor-nil+ } [ B{ 0xf6 } cbor> ] unit-test
{ +cbor-undefined+ } [ B{ 0xf7 } cbor> ] unit-test
{ T{ cbor-simple f 16 } } [ B{ 0xf0 } cbor> ] unit-test
{ T{ cbor-simple f 24 } } [ B{ 0xf8 0x18 } cbor> ] unit-test
{ T{ cbor-simple f 255 } } [ B{ 0xf8 0xff } cbor> ] unit-test
{ T{ cbor-tagged f 0 "2013-03-21T20:04:00Z" } } [ "c074323031332d30332d32315432303a30343a30305a" hex-string>bytes cbor> ] unit-test
{ T{ cbor-tagged f 1 1363896240 } } [ "c11a514b67b0" hex-string>bytes cbor> ] unit-test
{ T{ cbor-tagged f 1 1363896240.5 } } [ "c1fb41d452d9ec200000" hex-string>bytes cbor> ] unit-test
{ T{ cbor-tagged f 23 B{ 0x01 0x02 0x03 0x04 } } } [ "d74401020304" hex-string>bytes cbor> ] unit-test
{ T{ cbor-tagged f 24 B{ 0x64 0x49 0x45 0x54 0x46 } } } [ "d818456449455446" hex-string>bytes cbor> ] unit-test
{ T{ cbor-tagged f 32 "http://www.example.com" } } [ "d82076687474703a2f2f7777772e6578616d706c652e636f6d" hex-string>bytes cbor> ] unit-test
{ B{ } } [ B{ 0x40 } cbor> ] unit-test
{ B{ 1 2 3 4 } } [ B{ 0x44 0x01 0x02 0x03 0x04 } cbor> ] unit-test
{ "" } [ B{ 0x60 } cbor> ] unit-test
{ "a" } [ B{ 0x61 0x61 } cbor> ] unit-test
{ "IETF" } [ B{ 0x64 0x49 0x45 0x54 0x46 } cbor> ] unit-test
{ "\"\\" } [ B{ 0x62 0x22 0x5c } cbor> ] unit-test
{ "\u0000fc" } [ B{ 0x62 0xc3 0xbc } cbor> ] unit-test
{ "\u006c34" } [ B{ 0x63 0xe6 0xb0 0xb4 } cbor> ] unit-test
! FIXME { "\u00d800\u00dd51" } [ B{ 0x64 0xf0 0x90 0x85 0x91 } cbor> ] unit-test
{ { } } [ B{ 0x80 } cbor> ] unit-test
{ { 1 2 3 } } [ B{ 0x83 0x01 0x02 0x03 } cbor> ] unit-test
{ { 1 { 2 3 } { 4 5 } } } [ B{ 0x83 0x01 0x82 0x02 0x03 0x82 0x04 0x05 } cbor> ] unit-test
${ 25 [1,b] >array } [ "98190102030405060708090a0b0c0d0e0f101112131415161718181819" hex-string>bytes cbor> ] unit-test
{ { } } [ B{ 0xa0 } cbor> ] unit-test
{ { { 1 2 } { 3 4 } } } [ "a201020304" hex-string>bytes cbor> ] unit-test
{ { { "a" 1 } { "b" { 2 3 } } } } [ "a26161016162820203" hex-string>bytes cbor> ] unit-test
{ { "a" { { "b" "c" } } } } [ "826161a161626163" hex-string>bytes cbor> ] unit-test
{ { { "a" "A" } { "b" "B" } { "c" "C" } { "d" "D" } { "e" "E" } } } [ "a56161614161626142616361436164614461656145" hex-string>bytes cbor> ] unit-test
{ { 1 { 2 3 } { 4 5 } } } [ "9f018202039f0405ffff" hex-string>bytes cbor> ] unit-test
{ { 1 { 2 3 } { 4 5 } } } [ "9f01820203820405ff" hex-string>bytes cbor> ] unit-test
{ { 1 { 2 3 } { 4 5 } } } [ "83018202039f0405ff" hex-string>bytes cbor> ] unit-test
{ { 1 { 2 3 } { 4 5 } } } [ "83019f0203ff820405" hex-string>bytes cbor> ] unit-test
${ 25 [1,b] >array } [ "9f0102030405060708090a0b0c0d0e0f101112131415161718181819ff" hex-string>bytes cbor> ] unit-test
{ { { "a" 1 } { "b" { 2 3 } } } } [ "bf61610161629f0203ffff" hex-string>bytes cbor> ] unit-test
{ { "a" { { "b" "c" } } } } [ "826161bf61626163ff" hex-string>bytes cbor> ] unit-test
{ { { "Fun" t } { "Amt" -2 } } } [ "bf6346756ef563416d7421ff" hex-string>bytes cbor> ] unit-test
