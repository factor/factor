USING: io.encodings.string io.encodings.ascii tools.test strings arrays ;
IN: io.encodings.ascii.tests

[ B{ CHAR: f CHAR: o CHAR: o } ] [ "foo" ascii encode ] unit-test
[ { 128 } >string ascii encode ] must-fail
[ B{ 127 } ] [ { 127 } >string ascii encode ] unit-test

[ "bar" ] [ "bar" ascii decode ] unit-test
[ { CHAR: b HEX: fffd CHAR: r } ] [ B{ CHAR: b 233 CHAR: r } ascii decode >array ] unit-test
