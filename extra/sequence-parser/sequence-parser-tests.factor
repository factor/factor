USING: tools.test sequence-parser unicode.categories kernel
accessors ;
IN: sequence-parser.tests

[ "hello" ]
[ "hello" [ take-rest ] parse-sequence ] unit-test

[ "hi" " how are you?" ]
[
    "hi how are you?"
    [ [ [ current blank? ] take-until ] [ take-rest ] bi ] parse-sequence
] unit-test

[ "foo" ";bar" ]
[
    "foo;bar" [
        [ CHAR: ; take-until-object ] [ take-rest ] bi
    ] parse-sequence
] unit-test

[ "foo " "and bar" ]
[
    "foo and bar" [
        [ "and" take-until-sequence ] [ take-rest ] bi 
    ] parse-sequence
] unit-test

[ "foo " " bar" ]
[
    "foo and bar" [
        [ "and" take-until-sequence ]
        [ "and" take-sequence drop ]
        [ take-rest ] tri
    ] parse-sequence
] unit-test

[ "foo " " bar" ]
[
    "foo and bar" [
        [ "and" take-until-sequence* ]
        [ take-rest ] bi
    ] parse-sequence
] unit-test

[ { 1 2 } ]
[ { 1 2 3 4 } <sequence-parser> { 3 4 } take-until-sequence ] unit-test

[ f "aaaa" ]
[
    "aaaa" <sequence-parser>
    [ "b" take-until-sequence ] [ take-rest ] bi
] unit-test

[ 6 ]
[
    "      foo   " [ skip-whitespace n>> ] parse-sequence
] unit-test

[ { 1 2 } ]
[ { 1 2 3 } <sequence-parser> [ current 3 = ] take-until ] unit-test

[ "ab" ]
[ "abcd" <sequence-parser> "ab" take-sequence ] unit-test

[ f ]
[ "abcd" <sequence-parser> "lol" take-sequence ] unit-test

[ "ab" ]
[
    "abcd" <sequence-parser>
    [ "lol" take-sequence drop ] [ "ab" take-sequence ] bi
] unit-test

[ "" ]
[ "abcd" <sequence-parser> "" take-sequence ] unit-test

[ "cd" ]
[ "abcd" <sequence-parser> [ "ab" take-sequence drop ] [ "cd" take-sequence ] bi ] unit-test

[ f ]
[
    "\"abc\" asdf" <sequence-parser>
    [ CHAR: \ CHAR: " take-quoted-string drop ] [ "asdf" take-sequence ] bi
] unit-test

[ "abc\\\"def" ]
[
    "\"abc\\\"def\" asdf" <sequence-parser>
    CHAR: \ CHAR: " take-quoted-string
] unit-test

[ "asdf" ]
[
    "\"abc\" asdf" <sequence-parser>
    [ CHAR: \ CHAR: " take-quoted-string drop ]
    [ skip-whitespace "asdf" take-sequence ] bi
] unit-test

[ f ]
[
    "\"abc asdf" <sequence-parser>
    CHAR: \ CHAR: " take-quoted-string
] unit-test

[ "\"abc" ]
[
    "\"abc asdf" <sequence-parser>
    [ CHAR: \ CHAR: " take-quoted-string drop ]
    [ "\"abc" take-sequence ] bi
] unit-test

[ "c" ]
[ "c" <sequence-parser> take-token ] unit-test

[ f ]
[ "" <sequence-parser> take-token ] unit-test

[ "abcd e \\\"f g" ]
[ "\"abcd e \\\"f g\"" <sequence-parser> CHAR: \ CHAR: " take-token* ] unit-test

[ "" ]
[ "" <sequence-parser> take-rest ] unit-test

[ "" ]
[ "abc" <sequence-parser> dup "abc" take-sequence drop take-rest ] unit-test

[ f ]
[ "abc" <sequence-parser> "abcdefg" take-sequence ] unit-test

[ "1234" ]
[ "1234f" <sequence-parser> take-integer ] unit-test

[ "yes" ]
[
    "yes1234f" <sequence-parser>
    [ take-integer drop ] [ "yes" take-sequence ] bi 
] unit-test

[ f ] [ "" <sequence-parser> 4 take-n ] unit-test
[ "abcd" ] [ "abcd" <sequence-parser> 4 take-n ] unit-test
[ "abcd" "efg" ] [ "abcdefg" <sequence-parser> [ 4 take-n ] [ take-rest ] bi ] unit-test

[ "asdfasdf" ] [
    "/*asdfasdf*/" <sequence-parser> take-c-comment 
] unit-test

[ "k" ] [
    "/*asdfasdf*/k" <sequence-parser> [ take-c-comment drop ] [ take-rest ] bi
] unit-test

[ "omg" ] [
    "//asdfasdf\nomg" <sequence-parser>
    [ take-c++-comment drop ] [ take-rest ] bi
] unit-test

[ "omg" ] [
    "omg" <sequence-parser>
    [ take-c++-comment drop ] [ take-rest ] bi
] unit-test

[ "/*asdfasdf" ] [
    "/*asdfasdf" <sequence-parser> [ take-c-comment drop ] [ take-rest ] bi
] unit-test

[ "asdf" "eoieoei" ] [
    "//asdf\neoieoei" <sequence-parser>
    [ take-c++-comment ] [ take-rest ] bi
] unit-test

[ f "33asdf" ]
[ "33asdf" <sequence-parser> [ take-c-identifier ] [ take-rest ] bi ] unit-test

[ "asdf" ]
[ "asdf" <sequence-parser> take-c-identifier ] unit-test

[ "_asdf" ]
[ "_asdf" <sequence-parser> take-c-identifier ] unit-test

[ "_asdf400" ]
[ "_asdf400" <sequence-parser> take-c-identifier ] unit-test

[ "123" ]
[ "123jjj" <sequence-parser> take-c-integer ] unit-test

[ "123uLL" ]
[ "123uLL" <sequence-parser> take-c-integer ] unit-test

[ "123ull" ]
[ "123ull" <sequence-parser> take-c-integer ] unit-test

[ "123u" ]
[ "123u" <sequence-parser> take-c-integer ] unit-test

[ 36 ]
[
    "    //jofiejoe\n    //eoieow\n/*asdf*/\n      "
    <sequence-parser> skip-whitespace/comments n>>
] unit-test

[ f ]
[ "\n" <sequence-parser> take-integer ] unit-test

[ "\n" ] [ "\n" <sequence-parser> [ ] take-while ] unit-test
[ f ] [ "\n" <sequence-parser> [ not ] take-while ] unit-test
