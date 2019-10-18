IN: see.tests
USING: see tools.test io.streams.string math words ;

CONSTANT: test-const 10
[ "IN: see.tests\nCONSTANT: test-const 10 inline\n" ]
[ [ \ test-const see ] with-string-writer ] unit-test

ALIAS: test-alias +

[ "USING: math ;\nIN: see.tests\nALIAS: test-alias + inline\n" ]
[ [ \ test-alias see ] with-string-writer ] unit-test

[ ] [ gensym see ] unit-test