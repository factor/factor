USING: arrays io.encodings.latin1 io.encodings.string strings
tools.test ;

{ B{ char: f char: o char: o } } [ "foo" latin1 encode ] unit-test

[ { 256 } >string latin1 encode ] must-fail

{ B{ 255 } } [ { 255 } >string latin1 encode ] unit-test

{ "bar" } [ "bar" latin1 decode ] unit-test

{ { char: b 233 char: r } } [
    B{ char: b 233 char: r } latin1 decode >array
] unit-test
