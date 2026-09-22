USING: combinators io.encodings.utf8 io.streams.string kernel math
see sequences summary tools.test words ;
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

! #758
: fry-definition ( x -- quot ) '[ _ ] ;

{ "IN: see.tests\n: fry-definition ( x -- quot ) '[ _ ] ;\n" }
[ [ \ fry-definition see ] with-string-writer ] unit-test

! #2858: deep definitions must retain their contents and vocabulary uses.
: deeply-nested-definition ( -- quot )
    [ [ [ [ [ [ [ [ [ [ [ [ [ [ [ [ utf8 ] ] ] ] ] ] ] ] ] ] ] ] ] ] ] ] ;

{ f t t } [
    [ \ deeply-nested-definition see ] with-string-writer
    [ "~quotation~" swap subseq? ]
    [ "utf8" swap subseq? ]
    [ "io.encodings.utf8" swap subseq? ] tri
] unit-test
