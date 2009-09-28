! (c)2009 Joe Groff bsd license
USING: accessors alien.c-types alien.parser alien.syntax
tools.test vocabs.parser parser ;
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