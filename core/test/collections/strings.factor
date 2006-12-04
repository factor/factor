IN: temporary
USE: errors
USE: kernel
USE: math
USE: namespaces
USE: strings
USE: test
USE: sequences
USE: vectors

[ CHAR: b ] [ 1 >bignum "abc" nth ] unit-test

[ ] [ 10 [ [ -1000000 <sbuf> ] catch drop ] times ] unit-test

[ "abc" ] [ [ "a" "b" "c" ] [ [ % ] each ] "" make ] unit-test

[ "abc" ] [ "ab" "c" append ] unit-test
[ "abc" ] [ "a" "b" "c" append3 ] unit-test

[ 3 ] [ "a" "hola" start ] unit-test
[ -1 ] [ "x" "hola" start ] unit-test
[ 0 ] [ "" "a" start ] unit-test
[ 0 ] [ "" "" start ] unit-test
[ 0 ] [ "hola" "hola" start ] unit-test
[ 1 ] [ "ol" "hola" start ] unit-test
[ -1 ] [ "amigo" "hola" start ] unit-test
[ -1 ] [ "holaa" "hola" start ] unit-test

[ "Beginning" ] [ "Beginning and end" 9 head ] unit-test

[ f ] [ CHAR: I "team" member? ] unit-test
[ t ] [ "ea" "team" subseq? ] unit-test
[ f ] [ "actore" "Factor" subseq? ] unit-test

[ "end" ] [ "Beginning and end" 14 tail ] unit-test

[ "hello" "world" ] [ "hello world" " " split1 ] unit-test
[ "goodbye" f ] [ "goodbye" " " split1 ] unit-test
[ "" "" ] [ "great" "great" split1 ] unit-test

[ "and end" t ] [ "Beginning and end" "Beginning " ?head ] unit-test
[ "Beginning and end" f ] [ "Beginning and end" "Beginning x" ?head ] unit-test
[ "Beginning and end" f ] [ "Beginning and end" "eginning " ?head ] unit-test

[ "Beginning" t ] [ "Beginning and end" " and end" ?tail ] unit-test
[ "Beginning and end" f ] [ "Beginning and end" "Beginning x" ?tail ] unit-test
[ "Beginning and end" f ] [ "Beginning and end" "eginning " ?tail ] unit-test

[ { "This" "is" "a" "split" "sentence" } ]
[ "This is a split sentence" " " split ]
unit-test

[ { "OneWord" } ]
[ "OneWord" " " split ]
unit-test

[ { "a" "b" "c" "d" "e" "f" } ]
[ "aXbYcXdYeXf" "XY" split ] unit-test

[ { "" "" } ]
[ " " " " split ] unit-test

[ { "hey" } ]
[ "hey" " " split ] unit-test

[ "Hello world" t ] [ "Hello world\n" "\n" ?tail ] unit-test
[ "Hello world" f ] [ "Hello world" "\n" ?tail ] unit-test
[ "" t ] [ "\n" "\n" ?tail ] unit-test
[ "" f ] [ "" "\n" ?tail ] unit-test

[ t ] [ CHAR: a letter? ] unit-test
[ f ] [ CHAR: A letter? ] unit-test
[ f ] [ CHAR: a LETTER? ] unit-test
[ t ] [ CHAR: A LETTER? ] unit-test
[ t ] [ CHAR: 0 digit? ] unit-test
[ f ] [ CHAR: x digit? ] unit-test

[ t ] [ "abc" "abd" <=> 0 < ] unit-test
[ t ] [ "z" "abd" <=> 0 > ] unit-test

[ f ] [ [ 0 10 "hello" subseq ] catch not ] unit-test

[ { "hell" "o wo" "rld" } ] [ "hello world" 4 group ] unit-test

[ 4 ] [
    0 "There are Four Upper Case characters"
    [ LETTER? [ 1+ ] when ] each
] unit-test

[ "Replacing+spaces+with+plus" ]
[
    "Replacing spaces with plus"
    [ dup CHAR: \s = [ drop CHAR: + ] when ] map
]
unit-test

[ "05" ] [ "5" 2 CHAR: 0 pad-left ] unit-test
[ "666" ] [ "666" 2 CHAR: 0 pad-left ] unit-test

[ 1 "" nth ] unit-test-fails
[ -6 "hello" nth ] unit-test-fails

[ t ] [ "hello world" dup >vector >string = ] unit-test 

[ "ab" ] [ 2 "abc" resize-string ] unit-test
[ "abc\0\0\0" ] [ 6 "abc" resize-string ] unit-test

! Random tester found this
[ { kernel-error 3 12 -7 } ]
[ [ 2 -7 resize-string ] catch ] unit-test
