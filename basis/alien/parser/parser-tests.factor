! (c)2009 Joe Groff bsd license
USING: accessors alien.c-types alien.parser alien.syntax
tools.test vocabs.parser parser eval vocabs.parser debugger
continuations ;
IN: alien.parser.tests

TYPEDEF: char char2

SYMBOL: not-c-type

[
    "alien.parser.tests" use-vocab
    "alien.c-types" use-vocab

    [ int ] [ "int" parse-c-type ] unit-test
    [ { int 5 } ] [ "int[5]" parse-c-type ] unit-test
    [ { int 5 10 11 } ] [ "int[5][10][11]" parse-c-type ] unit-test
    [ void* ] [ "int*" parse-c-type ] unit-test
    [ void* ] [ "int**" parse-c-type ] unit-test
    [ void* ] [ "int***" parse-c-type ] unit-test
    [ void* ] [ "int****" parse-c-type ] unit-test
    [ char* ] [ "char*" parse-c-type ] unit-test
    [ void* ] [ "char**" parse-c-type ] unit-test
    [ void* ] [ "char***" parse-c-type ] unit-test
    [ void* ] [ "char****" parse-c-type ] unit-test
    [ char2 ] [ "char2" parse-c-type ] unit-test
    [ char* ] [ "char2*" parse-c-type ] unit-test

    [ "not-c-type" parse-c-type ] [ no-c-type? ] must-fail-with
    [ "not-word" parse-c-type ] [ error>> no-word-error? ] must-fail-with

] with-file-vocabs

! Reported by mnestic
TYPEDEF: int alien-parser-test-int ! reasonably unique name...

[ "OK!" ] [
    [
        "USE: specialized-arrays SPECIALIZED-ARRAY: alien-parser-test-int" eval( -- )
        ! after restart, we end up here
        "OK!"
    ] [ :1 ] recover
] unit-test