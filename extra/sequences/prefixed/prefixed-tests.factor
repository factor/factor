USING: arrays sequences sequences.prefixed tools.test ;

{ { 1 } } [ f 1 <prefixed> >array ] unit-test
{ { 1 2 3 4 } } [ { 2 3 4 } 1 <prefixed> >array ] unit-test
