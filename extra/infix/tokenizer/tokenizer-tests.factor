! Copyright (C) 2009 Philipp Brüschweiler
! See https://factorcode.org/license.txt for BSD license.
USING: infix.ast infix.tokenizer tools.test ;
IN: infix.tokenizer.tests

{ V{ T{ ast-value f 1 } } } [ "1" tokenize-infix ] unit-test
{ V{ T{ ast-value f 1.02 } CHAR: * T{ ast-value f 3 } } } [ "1.02*3" tokenize-infix ] unit-test
{ V{ T{ ast-value f 3 } CHAR: / CHAR: ( T{ ast-value f 3 } CHAR: + T{ ast-value f 4 } CHAR: ) } }
[ "3/(3+4)" tokenize-infix ] unit-test
{ V{ "foo"  CHAR: ( "x" CHAR: , "y" CHAR: , "z" CHAR: ) } } [ "foo(x,y,z)" tokenize-infix ] unit-test
{ V{ "arr"  CHAR: [ "x" CHAR: + T{ ast-value f 3 } CHAR: ] } }
[ "arr[x+3]" tokenize-infix ] unit-test
[ "1.0.4" tokenize-infix ] must-fail
{ V{ CHAR: + CHAR: ] T{ ast-value f 3.4 } CHAR: , "bar" } }
[ "+]3.4,bar" tokenize-infix ] unit-test
{ V{ "baz_34c" } } [ "baz_34c" tokenize-infix ] unit-test
{ V{ T{ ast-value f 34 } "c_baz" } } [ "34c_baz"  tokenize-infix ] unit-test
{ V{ CHAR: ( T{ ast-value f 1 } CHAR: + T{ ast-value f 2 } CHAR: ) } }
[ "(1+2)" tokenize-infix ] unit-test
{ V{ T{ ast-value f 1 } CHAR: + T{ ast-value f 2 } CHAR: / T{ ast-value f 3 } } }
[ "1\n+\r2\t/ 3" tokenize-infix ] unit-test
