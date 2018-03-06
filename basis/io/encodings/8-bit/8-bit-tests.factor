USING: arrays io.encodings.8-bit io.encodings.string strings
tools.test ;

{ B{ char: f char: o char: o } } [ "foo" latin2 encode ] unit-test
[ { 256 } >string latin2 encode ] must-fail
{ "bar" } [ "bar" latin2 decode ] unit-test
{ { char: b 233 char: r } } [ B{ char: b 233 char: r } latin2 decode >array ] unit-test

{ { 0xfffd 0x20AC } } [ B{ 0x81 0x80 } windows-1252 decode >array ] unit-test

{ B{ 255 } } [ { 255 } >string windows-1254 encode ] unit-test

{ { 0x221a 0x00b1 0x0040 } } [ B{ 0xfb 0xf1 0x40 } cp437 decode >array ] unit-test
