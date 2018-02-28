USING: arrays io.encodings.latin1 io.encodings.string strings
tools.test ;

{ B{ CHAR: f CHAR: o CHAR: o } } [ "foo" latin1 encode ] unit-test

[ { 256 } >string latin1 encode ] must-fail

{ B{ 255 } } [ { 255 } >string latin1 encode ] unit-test

{ "bar" } [ "bar" latin1 decode ] unit-test

{ { CHAR: b 233 CHAR: r } } [
    B{ CHAR: b 233 CHAR: r } latin1 decode >array
] unit-test
