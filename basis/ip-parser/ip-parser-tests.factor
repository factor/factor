
USING: ip-parser kernel sequences tools.test ;

{ "0.0.0.1" } [ "1" normalize-ipv4 ] unit-test
{ "1.0.0.2" } [ "1.2" normalize-ipv4 ] unit-test
{ "1.2.0.3" } [ "1.2.3" normalize-ipv4 ] unit-test
{ "1.2.3.4" } [ "1.2.3.4" normalize-ipv4 ] unit-test
[ "1.2.3.4.5" normalize-ipv4 ] must-fail
{ "0.0.0.255" } [ "255" normalize-ipv4 ] unit-test
{ "0.0.1.0" } [ "256" normalize-ipv4 ] unit-test

{ t } [
    {
        "1249763844" ! flat decimal
        "0112.0175.0342.0004" ! dotted octal
        "011237361004" ! flat octal
        "0x4A.0x7D.0xE2.0x04" ! dotted hex
        "0x4A7DE204" ! flat hex
        "74.0175.0xe2.4"
    } [ normalize-ipv4 "74.125.226.4" = ] all?
] unit-test

{ "74.125.226.4" } [ 1249763844 ipv4-ntoa ] unit-test
{ 1249763844 } [ "74.125.226.4" ipv4-aton ] unit-test

{ { 0 0 0 0 0 0 0 1 } } [ "::1" parse-ipv6 ] unit-test

{ t } [
    {
        "2001:0db8:0000:0000:0000:ff00:0042:8329"
        "2001:db8:0:0:0:ff00:42:8329"
        "2001:db8::ff00:42:8329"
    } [ parse-ipv6 { 8193 3512 0 0 0 65280 66 33577 } = ] all?
] unit-test

{ 1 } [ "::1" ipv6-aton ] unit-test
{ "::1" } [ 1 ipv6-ntoa ] unit-test
{ 0x10000000000000000000000000000 } [ "1::" ipv6-aton ] unit-test
{ "1::" } [ 0x10000000000000000000000000000 ipv6-ntoa ] unit-test
{ 0x10002000000000000000000030004 } [ "1:2::3:4" ipv6-aton ] unit-test
{ "1:2::3:4" } [ 0x10002000000000000000000030004 ipv6-ntoa ] unit-test

{ { 65152 0 0 0 29762 6399 65122 31588 } }
[ "fe80::7442:18ff:fe62:7b64%en0" parse-ipv6 ] unit-test
