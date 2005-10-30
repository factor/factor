USING: alien io kernel lists math prettyprint sequences
test words inference namespaces vectors ;
IN: temporary

[ "4" ] [ 4 unparse ] unit-test
[ "1.0" ] [ 1.0 unparse ] unit-test
[ "C{ 1/2 2/3 }" ] [ C{ 1/2 2/3 } unparse ] unit-test
[ "1267650600228229401496703205376" ] [ 1 100 shift unparse ] unit-test

[ "+" ] [ \ + unparse ] unit-test

[ "\\ +" ] [ [ \ + ] first unparse ] unit-test

[ "{ }" ] [ { } unparse ] unit-test

[ "{ 1 2 3 }" ] [ { 1 2 3 } unparse ] unit-test

[ "\"hello\\\\backslash\"" ]
[ "hello\\backslash" unparse ]
unit-test

[ "\"\\u1234\"" ]
[ "\u1234" unparse ]
unit-test

[ "\"\\e\"" ]
[ "\e" unparse ]
unit-test

[ "f" ] [ f unparse ] unit-test
[ "t" ] [ t unparse ] unit-test

[ "SBUF\" hello world\"" ] [ SBUF" hello world" unparse ] unit-test

: foo dup * ; inline

[ "IN: temporary : foo dup * ; inline\n" ]
[ [ \ foo see ] string-out ] unit-test

: bar ( x -- y ) 2 + ;

[ "IN: temporary : bar ( x -- y ) 2 + ;\n" ] [ [ \ bar see ] string-out ] unit-test

: baz dup ;

[ ] [ [ baz ] infer drop ] unit-test
[ "IN: temporary : baz ( object -- object object ) dup ;\n" ]
[ [ \ baz see ] string-out ] unit-test

[ ] [ \ fixnum see ] unit-test

[ ] [ \ integer see ] unit-test

[ ] [ \ general-t see ] unit-test

[ ] [ \ compound see ] unit-test

[ ] [ \ pprinter see ] unit-test

[ "ALIEN: 1234" ] [ 1234 <alien> unparse ] unit-test
