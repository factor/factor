
USING: kernel sequences tools.test ;

IN: ip-parser

{ "0.0.0.1" } [ "1" parse-ipv4 ] unit-test
{ "1.0.0.2" } [ "1.2" parse-ipv4 ] unit-test
{ "1.2.0.3" } [ "1.2.3" parse-ipv4 ] unit-test
{ "1.2.3.4" } [ "1.2.3.4" parse-ipv4 ] unit-test
[ "1.2.3.4.5" parse-ipv4 ] must-fail
{ "0.0.0.255" } [ "255" parse-ipv4 ] unit-test
{ "0.0.1.0" } [ "256" parse-ipv4 ] unit-test

{ t } [
    {
        "1249763844" ! flat decimal
        "0112.0175.0342.0004" ! dotted octal
        "011237361004" ! flat octal
        "0x4A.0x7D.0xE2.0x04" ! dotted hex
        "0x4A7DE204" ! flat hex
        "74.0175.0xe2.4"
    } [ parse-ipv4 "74.125.226.4" = ] all?
] unit-test
