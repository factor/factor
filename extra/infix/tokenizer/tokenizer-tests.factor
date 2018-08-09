! Copyright (C) 2009 Philipp Brüschweiler
! See http://factorcode.org/license.txt for BSD license.
USING: infix.ast infix.tokenizer tools.test ;
IN: infix.tokenizer.tests

{ V{ T{ ast-value f 1 } } } [ "1" tokenize-infix ] unit-test
{ V{ T{ ast-value f 1.02 } ch'* T{ ast-value f 3 } } } [ "1.02*3" tokenize-infix ] unit-test
{ V{ T{ ast-value f 3 } ch'/ ch'\( T{ ast-value f 3 } ch'+ T{ ast-value f 4 } ch'\) } }
[ "3/(3+4)" tokenize-infix ] unit-test
{ V{ "foo"  ch'\( "x" ch', "y" ch', "z" ch'\) } } [ "foo(x,y,z)" tokenize-infix ] unit-test
{ V{ "arr"  ch'\[ "x" ch'+ T{ ast-value f 3 } ch'\] } }
[ "arr[x+3]" tokenize-infix ] unit-test
[ "1.0.4" tokenize-infix ] must-fail
{ V{ ch'+ ch'\] T{ ast-value f 3.4 } ch', "bar" } }
[ "+]3.4,bar" tokenize-infix ] unit-test
{ V{ "baz_34c" } } [ "baz_34c" tokenize-infix ] unit-test
{ V{ T{ ast-value f 34 } "c_baz" } } [ "34c_baz"  tokenize-infix ] unit-test
{ V{ ch'\( T{ ast-value f 1 } ch'+ T{ ast-value f 2 } ch'\) } }
[ "(1+2)" tokenize-infix ] unit-test
{ V{ T{ ast-value f 1 } ch'+ T{ ast-value f 2 } ch'/ T{ ast-value f 3 } } }
[ "1\n+\r2\t/ 3" tokenize-infix ] unit-test
