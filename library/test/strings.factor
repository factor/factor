IN: temporary
USE: errors
USE: kernel
USE: math
USE: namespaces
USE: strings
USE: test

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

[ "Beginning" ] [ 9 "Beginning and end" string-head ] unit-test

[ f ] [ "I" "team" string-contains? ] unit-test
[ t ] [ "ea" "team" string-contains? ] unit-test
[ f ] [ "actore" "Factor" string-contains? ] unit-test

[ "end" ] [ 14 "Beginning and end" string-tail ] unit-test

[ "Beginning" " and end" ] [ "Beginning and end" 9 string/ ] unit-test

[ "Beginning" "and end" ] [ "Beginning and end" 9 string// ] unit-test

[ "hello" "world" ] [ "hello world" " " split1 ] unit-test
[ "goodbye" f ] [ "goodbye" " " split1 ] unit-test
[ "" "" ] [ "great" "great" split1 ] unit-test

[ "and end" t ] [ "Beginning and end" "Beginning " ?string-head ] unit-test
[ "Beginning and end" f ] [ "Beginning and end" "Beginning x" ?string-head ] unit-test
[ "Beginning and end" f ] [ "Beginning and end" "eginning " ?string-head ] unit-test

[ "Beginning" t ] [ "Beginning and end" " and end" ?string-tail ] unit-test
[ "Beginning and end" f ] [ "Beginning and end" "Beginning x" ?string-tail ] unit-test
[ "Beginning and end" f ] [ "Beginning and end" "eginning " ?string-tail ] unit-test

[ [ "This" "is" "a" "split" "sentence" ] ]
[ "This is a split sentence" " " split ]
unit-test

[ [ "OneWord" ] ]
[ "OneWord" " " split ]
unit-test

[ [ "a" "b" "c" "d" "e" "f" ] ]
[ "aXXbXXcXXdXXeXXf" "XX" split ] unit-test

[ "Hello world" t ] [ "Hello world\n" "\n" ?string-tail ] unit-test
[ "Hello world" f ] [ "Hello world" "\n" ?string-tail ] unit-test
[ "" t ] [ "\n" "\n" ?string-tail ] unit-test
[ "" f ] [ "" "\n" ?string-tail ] unit-test

[ t ] [ CHAR: a letter? ] unit-test
[ f ] [ CHAR: A letter? ] unit-test
[ f ] [ CHAR: a LETTER? ] unit-test
[ t ] [ CHAR: A LETTER? ] unit-test
[ t ] [ CHAR: 0 digit? ] unit-test
[ f ] [ CHAR: x digit? ] unit-test

[ t ] [ "abc" "abd" string-compare 0 < ] unit-test
[ t ] [ "z" "abd" string-compare 0 > ] unit-test

[ f ] [ [ 0 10 "hello" substring ] [ not ] catch ] unit-test

[ [ "hell" "o wo" "rld" ] ] [ 4 "hello world" split-n ] unit-test

[ 4 ] [
    0 "There are Four Upper Case characters"
    [ LETTER? [ 1 + ] when ] string-each
] unit-test

[ "Replacing+spaces+with+plus" ]
[
    "Replacing spaces with plus"
    [ dup CHAR: \s = [ drop CHAR: + ] when ] string-map
]
unit-test

[ "05" ] [ "5" 2 "0" pad ] unit-test
[ "666" ] [ "666" 2 "0" pad ] unit-test
