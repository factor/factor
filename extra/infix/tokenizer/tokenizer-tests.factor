! Copyright (C) 2009 Philipp Brüschweiler
! See http://factorcode.org/license.txt for BSD license.
USING: infix.ast infix.tokenizer tools.test ;
IN: infix.tokenizer.tests

{ V{ T{ ast-value f 1 } } } [ "1" tokenize-infix ] unit-test
{ V{ T{ ast-value f 1.02 } char: * T{ ast-value f 3 } } } [ "1.02*3" tokenize-infix ] unit-test
{ V{ T{ ast-value f 3 } char: / char: \( T{ ast-value f 3 } char: + T{ ast-value f 4 } char: \) } }
[ "3/(3+4)" tokenize-infix ] unit-test
{ V{ "foo"  char: \( "x" char: , "y" char: , "z" char: \) } } [ "foo(x,y,z)" tokenize-infix ] unit-test
{ V{ "arr"  char: \[ "x" char: + T{ ast-value f 3 } char: \] } }
[ "arr[x+3]" tokenize-infix ] unit-test
[ "1.0.4" tokenize-infix ] must-fail
{ V{ char: + char: \] T{ ast-value f 3.4 } char: , "bar" } }
[ "+]3.4,bar" tokenize-infix ] unit-test
{ V{ "baz_34c" } } [ "baz_34c" tokenize-infix ] unit-test
{ V{ T{ ast-value f 34 } "c_baz" } } [ "34c_baz"  tokenize-infix ] unit-test
{ V{ char: \( T{ ast-value f 1 } char: + T{ ast-value f 2 } char: \) } }
[ "(1+2)" tokenize-infix ] unit-test
{ V{ T{ ast-value f 1 } char: + T{ ast-value f 2 } char: / T{ ast-value f 3 } } }
[ "1\n+\r2\t/ 3" tokenize-infix ] unit-test
