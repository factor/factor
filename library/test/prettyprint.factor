USING: alien definitions inference io kernel math namespaces
parser prettyprint sequences test vectors words ;
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


[ "( a b -- c d )" ] [
    { "a" "b" } { "c" "d" } <effect> effect>string
] unit-test

[ "( -- c d )" ] [
    { } { "c" "d" } <effect> effect>string
] unit-test

[ "( a b -- )" ] [
    { "a" "b" } { } <effect> effect>string
] unit-test

[ "( -- )" ] [
    { } { } <effect> effect>string
] unit-test

[ "ALIEN: 1234" ] [ 1234 <alien> unparse ] unit-test

[ "W{ \\ + }" ] [ [ W{ \ + } ] first unparse ] unit-test

[ "[ 1 2 DUP ]" ]
[
    [ 1 2 dup ] dup hilite-quotation set 2 hilite-index set
    [ pprint ] string-out
] unit-test

: foo ( a -- b ) dup * ; inline

[ "IN: temporary : foo ( a -- b ) dup * ; inline\n" ]
[ [ \ foo see ] string-out ] unit-test

: bar ( x -- y ) 2 + ;

[ "IN: temporary : bar ( x -- y ) 2 + ;\n" ]
[ [ \ bar see ] string-out ] unit-test

[ ] [ \ fixnum see ] unit-test

[ ] [ \ integer see ] unit-test

[ ] [ \ general-t see ] unit-test

[ ] [ \ compound see ] unit-test

[ ] [ \ duplex-stream see ] unit-test
