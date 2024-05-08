USING: arrays sequences sequences.suffixed tools.test ;

{ { 1 } } [ f 1 <suffixed> >array ] unit-test
{ { 1 2 3 4 } } [ { 1 2 3 } 4 <suffixed> >array ] unit-test
