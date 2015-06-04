USING: contributors kernel system tools.test ;
IN: contributors.tests

"." install-prefix = [
    { } [ contributors ] unit-test
] when
