USING: base85 byte-arrays kernel sequences strings tools.test ;

{ t } [ 256 <iota> >byte-array dup >base85 base85> = ] unit-test

{ "NM!" } [ "He" >base85 >string ] unit-test
{ t } [ "He" dup >base85 base85> >string = ] unit-test

{ "00" } [ B{ 0 } >base85 >string ] unit-test
{ "\0" } [ "00" base85> >string ] unit-test
