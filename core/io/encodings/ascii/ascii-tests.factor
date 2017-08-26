USING: arrays io.encodings.ascii io.encodings.string strings
tools.test ;

{ B{ char: f char: o char: o } } [ "foo" ascii encode ] unit-test
[ { 128 } >string ascii encode ] must-fail
{ B{ 127 } } [ { 127 } >string ascii encode ] unit-test

{ "bar" } [ "bar" ascii decode ] unit-test
{ { char: b 0xfffd char: r } } [ B{ char: b 233 char: r } ascii decode >array ] unit-test
