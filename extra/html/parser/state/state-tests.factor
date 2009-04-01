USING: tools.test html.parser.state ascii kernel accessors ;
IN: html.parser.state.tests

[ "hello" ]
[ "hello" [ take-rest ] state-parse ] unit-test

[ "hi" " how are you?" ]
[
    "hi how are you?"
    [ [ [ current blank? ] take-until ] [ take-rest ] bi ] state-parse
] unit-test

[ "foo" ";bar" ]
[
    "foo;bar" [
        [ CHAR: ; take-until-object ] [ take-rest ] bi
    ] state-parse
] unit-test

[ "foo " " bar" ]
[
    "foo and bar" [
        [ "and" take-until-sequence ] [ take-rest ] bi 
    ] state-parse
] unit-test

[ 6 ]
[
    "      foo   " [ skip-whitespace n>> ] state-parse
] unit-test

[ { 1 2 } ]
[ { 1 2 3 } <state-parser> [ current 3 = ] take-until ] unit-test

[ { 1 2 } ]
[ { 1 2 3 4 } <state-parser> { 3 4 } take-until-sequence ] unit-test
