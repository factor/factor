IN: temporary
USING: io kernel lists math prettyprint sequences test words ;

[ "4" ] [ 4 pprint>string ] unit-test
[ "1.0" ] [ 1.0 pprint>string ] unit-test
[ "#{ 1/2 2/3 }#" ] [ #{ 1/2 2/3 }# pprint>string ] unit-test
[ "1267650600228229401496703205376" ] [ 1 100 shift pprint>string ] unit-test

[ "+" ] [ \ + pprint>string ] unit-test

[ "\\ +" ] [ [ \ + ] first pprint>string ] unit-test

[ "1" ] [
    [ [ <block 1 pprint-object block> ] with-pprint ] string-out
] unit-test

[ "{ }" ] [ { } pprint>string ] unit-test

[ "{ 1 2 3 }" ] [ { 1 2 3 } pprint>string ] unit-test

[ "\"hello\\\\backslash\"" ]
[ "hello\\backslash" pprint>string ]
unit-test

[ "\"\\u1234\"" ]
[ "\u1234" pprint>string ]
unit-test

[ "\"\\e\"" ]
[ "\e" pprint>string ]
unit-test

[ "f" ] [ f pprint>string ] unit-test
[ "t" ] [ t pprint>string ] unit-test

[ "SBUF\" hello world\"" ] [ SBUF" hello world" pprint>string ] unit-test

: foo dup * ; inline

[ "IN: temporary\n: foo dup * ; inline\n" ]
[ [ \ foo see ] string-out ] unit-test

[ ] [ \ fixnum see ] unit-test

[ ] [ \ integer see ] unit-test

[ ] [ \ general-t see ] unit-test

[ ] [ \ compound see ] unit-test

[ ] [ \ pprinter see ] unit-test
