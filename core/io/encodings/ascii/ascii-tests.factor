USING: arrays io.encodings.ascii io.encodings.string strings
tools.test ;

{ B{ ch'f ch'o ch'o } } [ "foo" ascii encode ] unit-test
[ { 128 } >string ascii encode ] must-fail
{ B{ 127 } } [ { 127 } >string ascii encode ] unit-test

{ "bar" } [ "bar" ascii decode ] unit-test
{ { ch'b 0xfffd ch'r } } [ B{ ch'b 233 ch'r } ascii decode >array ] unit-test
