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

[ "ab" ]
[ "abcd" <state-parser> "ab" take-sequence ] unit-test

[ f ]
[ "abcd" <state-parser> "lol" take-sequence ] unit-test

[ "ab" ]
[
    "abcd" <state-parser>
    [ "lol" take-sequence drop ] [ "ab" take-sequence ] bi
] unit-test

[ "" ]
[ "abcd" <state-parser> "" take-sequence ] unit-test

[ "cd" ]
[ "abcd" <state-parser> [ "ab" take-sequence drop ] [ "cd" take-sequence ] bi ] unit-test


[ f ]
[
    "\"abc\" asdf" <state-parser>
    [ CHAR: \ CHAR: " take-quoted-string drop ] [ "asdf" take-sequence ] bi
] unit-test

[ "asdf" ]
[
    "\"abc\" asdf" <state-parser>
    [ CHAR: \ CHAR: " take-quoted-string drop ]
    [ skip-whitespace "asdf" take-sequence ] bi
] unit-test

[ f ]
[
    "\"abc asdf" <state-parser>
    CHAR: \ CHAR: " take-quoted-string
] unit-test

[ "\"abc" ]
[
    "\"abc asdf" <state-parser>
    [ CHAR: \ CHAR: " take-quoted-string drop ]
    [ "\"abc" take-sequence ] bi
] unit-test
