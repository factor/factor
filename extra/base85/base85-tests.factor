USING: kernel strings tools.test ;
IN: base85

{ t } [ "Hello, world" dup >base85 base85> >string = ] unit-test
