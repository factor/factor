USING: arrays io.encodings.ascii io.encodings.string strings
tools.test ;

{ B{ CHAR: f CHAR: o CHAR: o } } [ "foo" ascii encode ] unit-test
[ { 128 } >string ascii encode ] must-fail
{ B{ 127 } } [ { 127 } >string ascii encode ] unit-test

{ "bar" } [ "bar" ascii decode ] unit-test
{ { CHAR: b 0xfffd CHAR: r } } [ B{ CHAR: b 233 CHAR: r } ascii decode >array ] unit-test
