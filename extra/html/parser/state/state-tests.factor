USING: tools.test html.parser.state ascii kernel accessors ;
IN: html.parser.state.tests

[ "hello" ]
[ "hello" [ take-rest ] string-parse ] unit-test

[ "hi" " how are you?" ]
[
    "hi how are you?"
    [ [ [ blank? ] take-until ] [ take-rest ] bi ] string-parse
] unit-test

[ "foo" ";bar" ]
[
    "foo;bar" [
        [ CHAR: ; take-until-char ] [ take-rest ] bi
    ] string-parse
] unit-test

[ "foo " " bar" ]
[
    "foo and bar" [
        [ "and" take-until-string ] [ take-rest ] bi 
    ] string-parse
] unit-test

[ 6 ]
[
    "      foo   " [ skip-whitespace i>> ] string-parse
] unit-test
