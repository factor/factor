USING: arrays sequences sequences.prefixed tools.test ;

{ { 1 } } [ 1 f <prefixed> >array ] unit-test
{ { 1 2 3 4 } } [ 1 { 2 3 4 } <prefixed> >array ] unit-test
