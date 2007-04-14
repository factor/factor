USING: io.encodings.string io.encodings.8-bit tools.test strings arrays ;
IN: io.encodings.8-bit.tests

[ B{ CHAR: f CHAR: o CHAR: o } ] [ "foo" latin1 encode ] unit-test
[ { 256 } >string latin1 encode ] must-fail
[ B{ 255 } ] [ { 255 } latin1 encode ] unit-test

[ "bar" ] [ "bar" latin1 decode ] unit-test
[ { CHAR: b 233 CHAR: r } ] [ { CHAR: b 233 CHAR: r } latin1 decode >array ] unit-test
[ { HEX: fffd HEX: 20AC } ] [ { HEX: 81 HEX: 80 } windows-1252 decode >array ] unit-test
