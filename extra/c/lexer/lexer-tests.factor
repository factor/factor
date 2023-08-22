! Copyright (C) 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors c.lexer kernel sequences.parser tools.test ;
IN: c.lexer.tests

{ 36 }
[
    "    //jofiejoe\n    //eoieow\n/*asdf*/\n      "
    <sequence-parser> skip-whitespace/comments n>>
] unit-test

{ f "33asdf" }
[ "33asdf" <sequence-parser> [ take-c-identifier ] [ take-rest ] bi ] unit-test

{ "asdf" }
[ "asdf" <sequence-parser> take-c-identifier ] unit-test

{ "_asdf" }
[ "_asdf" <sequence-parser> take-c-identifier ] unit-test

{ "_asdf400" }
[ "_asdf400" <sequence-parser> take-c-identifier ] unit-test

{ "asdfasdf" } [
    "/*asdfasdf*/" <sequence-parser> take-c-comment
] unit-test

{ "k" } [
    "/*asdfasdf*/k" <sequence-parser> [ take-c-comment drop ] [ take-rest ] bi
] unit-test

{ "omg" } [
    "//asdfasdf\nomg" <sequence-parser>
    [ take-c++-comment drop ] [ take-rest ] bi
] unit-test

{ "omg" } [
    "omg" <sequence-parser>
    [ take-c++-comment drop ] [ take-rest ] bi
] unit-test

{ "/*asdfasdf" } [
    "/*asdfasdf" <sequence-parser> [ take-c-comment drop ] [ take-rest ] bi
] unit-test

{ "asdf" "eoieoei" } [
    "//asdf\neoieoei" <sequence-parser>
    [ take-c++-comment ] [ take-rest ] bi
] unit-test

{ f }
[
    "\"abc\" asdf" <sequence-parser>
    [ CHAR: \ CHAR: \" take-quoted-string drop ] [ "asdf" take-sequence ] bi
] unit-test

{ "abc\\\"def" }
[
    "\"abc\\\"def\" asdf" <sequence-parser>
    CHAR: \ CHAR: \" take-quoted-string
] unit-test

{ "asdf" }
[
    "\"abc\" asdf" <sequence-parser>
    [ CHAR: \ CHAR: \" take-quoted-string drop ]
    [ skip-whitespace "asdf" take-sequence ] bi
] unit-test

{ f }
[
    "\"abc asdf" <sequence-parser>
    CHAR: \ CHAR: \" take-quoted-string
] unit-test

{ "\"abc" }
[
    "\"abc asdf" <sequence-parser>
    [ CHAR: \ CHAR: \" take-quoted-string drop ]
    [ "\"abc" take-sequence ] bi
] unit-test

{ "c" }
[ "c" <sequence-parser> take-token ] unit-test

{ f }
[ "" <sequence-parser> take-token ] unit-test

{ "abcd e \\\"f g" }
[ "\"abcd e \\\"f g\"" <sequence-parser> CHAR: \ CHAR: \" take-token* ] unit-test

{ "123" }
[ "123jjj" <sequence-parser> take-c-integer ] unit-test

{ "123uLL" }
[ "123uLL" <sequence-parser> take-c-integer ] unit-test

{ "123ull" }
[ "123ull" <sequence-parser> take-c-integer ] unit-test

{ "123u" }
[ "123u" <sequence-parser> take-c-integer ] unit-test
