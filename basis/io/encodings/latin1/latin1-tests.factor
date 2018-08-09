USING: arrays io.encodings.latin1 io.encodings.string strings
tools.test ;

{ B{ ch'f ch'o ch'o } } [ "foo" latin1 encode ] unit-test

[ { 256 } >string latin1 encode ] must-fail

{ B{ 255 } } [ { 255 } >string latin1 encode ] unit-test

{ "bar" } [ "bar" latin1 decode ] unit-test

{ { ch'b 233 ch'r } } [
    B{ ch'b 233 ch'r } latin1 decode >array
] unit-test
