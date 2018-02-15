USING: io.encodings.strict io.encodings.ascii tools.test
arrays io.encodings.string ;

{ { 0xfffd } } [ { 128 } ascii decode >array ] unit-test
[ { 128 } ascii strict decode ] must-fail
