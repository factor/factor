USING: base85 kernel strings tools.test ;

{ t } [ "Hello, world" dup >base85 base85> >string = ] unit-test
{ t } [ "ready" dup >base85 base85> >string = ] unit-test

{ "NM!" } [ "He" >base85 >string ] unit-test
{ t } [ "He" dup >base85 base85> >string = ] unit-test

{ "00" } [ B{ 0 } >base85 >string ] unit-test
{ "\0" } [ "00" base85> >string ] unit-test
