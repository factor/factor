IN: scratchpad
USE: errors
USE: kernel
USE: math
USE: namespaces
USE: strings
USE: test

[ f ] [ "a" "b" "c" =? ] unit-test
[ "c" ] [ "a" "a" "c" =? ] unit-test

[ f ] [ "A string." f-or-"" ] unit-test
[ t ] [ "" f-or-"" ] unit-test
[ t ] [ f f-or-"" ] unit-test

[ "abc" ] [ [ "a" "b" "c" ] cat ] unit-test

[ "abc" ] [ "ab" "c" cat2 ] unit-test
[ "abc" ] [ "a" "b" "c" cat3 ] unit-test

[ 3 ] [ "hola" "a" index-of ] unit-test
[ -1 ] [ "hola" "x" index-of ] unit-test
[ 0 ] [ "a" "" index-of ] unit-test
[ 0 ] [ "" "" index-of ] unit-test
[ 0 ] [ "hola" "hola" index-of ] unit-test
[ 1 ] [ "hola" "ol" index-of ] unit-test
[ -1 ] [ "hola" "amigo" index-of ] unit-test
[ -1 ] [ "hola" "holaa" index-of ] unit-test

[ "Beginning" ] [ 9 "Beginning and end" str-head ] unit-test

[ f ] [ "I" "team" str-contains? ] unit-test
[ t ] [ "ea" "team" str-contains? ] unit-test
[ f ] [ "actore" "Factor" str-contains? ] unit-test

[ "end" ] [ 14 "Beginning and end" str-tail ] unit-test

[ "Beginning" " and end" ] [ "Beginning and end" 9 str/ ] unit-test

[ "Beginning" "and end" ] [ "Beginning and end" 9 str// ] unit-test

[ "hello" "world" ] [ "hello world" " " split1 ] unit-test
[ "goodbye" f ] [ "goodbye" " " split1 ] unit-test
[ "" "" ] [ "great" "great" split1 ] unit-test

[ "and end" t ] [ "Beginning and end" "Beginning " ?str-head ] unit-test
[ "Beginning and end" f ] [ "Beginning and end" "Beginning x" ?str-head ] unit-test
[ "Beginning and end" f ] [ "Beginning and end" "eginning " ?str-head ] unit-test

[ "Beginning" t ] [ "Beginning and end" " and end" ?str-tail ] unit-test
[ "Beginning and end" f ] [ "Beginning and end" "Beginning x" ?str-tail ] unit-test
[ "Beginning and end" f ] [ "Beginning and end" "eginning " ?str-tail ] unit-test

[ [ "This" "is" "a" "split" "sentence" ] ]
[ "This is a split sentence" " " split ]
unit-test

[ [ "OneWord" ] ]
[ "OneWord" " " split ]
unit-test

[ [ "a" "b" "c" "d" "e" "f" ] ]
[ "aXXbXXcXXdXXeXXf" "XX" split ] unit-test

[ "Hello world" t ] [ "Hello world\n" "\n" ?str-tail ] unit-test
[ "Hello world" f ] [ "Hello world" "\n" ?str-tail ] unit-test
[ "" t ] [ "\n" "\n" ?str-tail ] unit-test
[ "" f ] [ "" "\n" ?str-tail ] unit-test

[ t ] [ CHAR: a letter? ] unit-test
[ f ] [ CHAR: A letter? ] unit-test
[ f ] [ CHAR: a LETTER? ] unit-test
[ t ] [ CHAR: A LETTER? ] unit-test
[ t ] [ CHAR: 0 digit? ] unit-test
[ f ] [ CHAR: x digit? ] unit-test

[ t ] [ "abc" "abd" str-compare 0 < ] unit-test
[ t ] [ "z" "abd" str-compare 0 > ] unit-test

[ "fedcba" ] [ "abcdef" str-reverse ] unit-test
[ "edcba" ] [ "abcde" str-reverse ] unit-test

[ f ] [ [ 0 10 "hello" substring ] [ not ] catch ] unit-test

[ [ "hell" "o wo" "rld" ] ] [ 4 "hello world" split-n ] unit-test

[ 4 ] [
    0 "There are Four Upper Case characters"
    [ LETTER? [ succ ] when ] str-each
] unit-test

[ "Replacing+spaces+with+plus" ]
[
    "Replacing spaces with plus"
    [ dup CHAR: \s = [ drop CHAR: + ] when ] str-map
]
unit-test

[ "05" ] [ "5" 2 "0" pad ] unit-test
[ "666" ] [ "666" 2 "0" pad ] unit-test
