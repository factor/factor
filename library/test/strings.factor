IN: scratchpad
USE: arithmetic
USE: combinators
USE: kernel
USE: namespaces
USE: strings
USE: test

[ f ] [ "A string." f-or-"" ] unit-test
[ t ] [ "" f-or-"" ] unit-test
[ t ] [ f f-or-"" ] unit-test

[ "abc" ] [ [ "a" "b" "c" ] cat ] unit-test

[ "abc" ] [ "ab" "c" cat2 ] unit-test
[ "abc" ] [ "a" "b" "c" cat3 ] unit-test
[ "abcd" ] [ "a" "b" "c" "d" cat4 ] unit-test
[ "abcde" ] [ "a" "b" "c" "d" "e" cat5 ] unit-test

[ 3 ] [ "hola" "a" index-of ] unit-test
[ -1 ] [ "hola" "x" index-of ] unit-test
[ 0 ] [ "a" "" index-of ] unit-test
[ 0 ] [ "" "" index-of ] unit-test
[ 0 ] [ "hola" "hola" index-of ] unit-test
[ 1 ] [ "hola" "ol" index-of ] unit-test
[ -1 ] [ "hola" "amigo" index-of ] unit-test
[ -1 ] [ "hola" "holaa" index-of ] unit-test

[ "Beginning" ] [ "Beginning and end" 9 str-head ] unit-test

[ f ] [ "I" "team" str-contains? ] unit-test
[ t ] [ "ea" "team" str-contains? ] unit-test
[ f ] [ "actore" "Factor" str-contains? ] unit-test

[ "end" ] [ "Beginning and end" 14 str-tail ] unit-test

[ "Beginning" " and end" ] [ "Beginning and end" 9 str/ ] unit-test

[ "Beginning" "and end" ] [ "Beginning and end" 9 str// ] unit-test

[ "hello" "world" ] [ "hello world" " " split1 ] unit-test
[ "goodbye" f ] [ "goodbye" " " split1 ] unit-test
[ "" "" ] [ "great" "great" split1 ] unit-test

[ "and end" ] [ "Beginning and end" "Beginning " str-head? ] unit-test
[ f ] [ "Beginning and end" "Beginning x" str-head? ] unit-test
[ f ] [ "Beginning and end" "eginning " str-head? ] unit-test

[ "Beginning" ] [ "Beginning and end" " and end" str-tail? ] unit-test
[ f ] [ "Beginning and end" "Beginning x" str-tail? ] unit-test
[ f ] [ "Beginning and end" "eginning " str-tail? ] unit-test

[ [ "This" "is" "a" "split" "sentence" ] ]
[ "This is a split sentence" " " split ]
unit-test

[ [ "OneWord" ] ]
[ "OneWord" " " split ]
unit-test

[ [ "a" "b" "c" "d" "e" "f" ] ]
[ "aXXbXXcXXdXXeXXf" "XX" split ] unit-test

[ 6 ]
[
    [ "One" "Two" "Little" "Piggy" "Went" "To" "The" "Market" ]
    max-str-length
] unit-test

[ "Hello world" ] [ "Hello world\n" ends-with-newline? ] unit-test
[ f ] [ "Hello world" ends-with-newline? ] unit-test
[ "" ] [ "\n" ends-with-newline? ] unit-test
[ f ] [ "" ends-with-newline? ] unit-test

[ t ] [ CHAR: a letter? ] unit-test
[ f ] [ CHAR: A letter? ] unit-test
[ f ] [ CHAR: a LETTER? ] unit-test
[ t ] [ CHAR: A LETTER? ] unit-test
[ t ] [ CHAR: 0 digit? ] unit-test
[ f ] [ CHAR: x digit? ] unit-test

[ t ] [ "abc" "abd" str-compare 0 < ] unit-test
[ t ] [ "z" "abd" str-compare 0 > ] unit-test

native? [
    [ t ] [ "Foo" str>sbuf "Foo" str>sbuf = ] unit-test
    [ f ] [ "Foo" str>sbuf "Foob" str>sbuf = ] unit-test
    [ f ] [ 34 "Foo" str>sbuf = ] unit-test
    
    [ "Hello" ] [
        100 <sbuf> "buf" set
        "Hello" "buf" get sbuf-append
        "buf" get clone "buf-clone" set
        "World" "buf-clone" get sbuf-append
        "buf" get sbuf>str
    ] unit-test
] when
