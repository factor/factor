USING: see tools.test io.streams.string math sequences summary
words ;
IN: see.tests

CONSTANT: test-const 10

{ "IN: see.tests\nCONSTANT: test-const 10 inline\n" }
[ [ \ test-const see ] with-string-writer ] unit-test

{ "IN: math\nERROR: non-negative-number-expected n ;\n" }
[ [ \ non-negative-number-expected see ] with-string-writer ] unit-test

ALIAS: test-alias +

{ "USING: math ;\nIN: see.tests\nALIAS: test-alias + inline\n" }
[ [ \ test-alias see ] with-string-writer ] unit-test

{ "IN: see.tests ALIAS: test-alias ( x y -- z )" }
[ \ test-alias summary ] unit-test

{ } [ gensym see ] unit-test

