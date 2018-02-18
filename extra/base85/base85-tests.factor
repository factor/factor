USING: base85 kernel strings tools.test ;

{ t } [ "Hello, world" dup >base85 base85> >string = ] unit-test

{ "NM!&3" } [ "He" >base85 >string ] unit-test
{ t } [ "He" dup >base85 base85> >string = ] unit-test
