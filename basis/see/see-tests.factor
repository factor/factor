USING: arrays io.encodings.utf8 io.streams.string kernel literals
math prettyprint.config see sequences summary tools.test words ;
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

! #1561
CONSTANT: long-definition $[ 200 <iota> >array ]

{ t f } [
    [ \ long-definition see ] with-string-writer
    [ " more~" subseq-of? ] [ "199" subseq-of? ] bi
] unit-test

{ f t } [
    [ [ \ long-definition see ] without-limits ] with-string-writer
    [ " more~" subseq-of? ] [ "199" subseq-of? ] bi
] unit-test

! #2858
: deeply-nested-definition ( -- quot )
    [ [ [ [ [ [ [ [ [ [ [ [ [ [ [ [ utf8 ] ] ] ] ] ] ] ] ] ] ] ] ] ] ] ] ;

{ t f } [
    [ \ deeply-nested-definition see ] with-string-writer
    [ "~quotation~" subseq-of? ] [ "io.encodings.utf8" subseq-of? ] bi
] unit-test

{ f t } [
    [ [ \ deeply-nested-definition see ] without-limits ] with-string-writer
    [ "~quotation~" subseq-of? ] [ "io.encodings.utf8" subseq-of? ] bi
] unit-test
