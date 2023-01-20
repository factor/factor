! Copyright (C) 2009 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.parser alien.parser.private
alien.syntax compiler.units continuations debugger eval kernel
lexer namespaces parser sequences sets summary tools.test
vocabs.parser words ;
IN: alien.parser.tests

<<

: with-parsing ( lines quot -- )
    [ <lexer> ] [ '[ _ with-compilation-unit ] ] bi* with-lexer ; inline

! (CREATE-C-TYPE)
{ "hello" } [
    { "hello" } [ CREATE-C-TYPE name>> ] with-parsing
] unit-test

! Check that it deletes from old-definitions
{ 0 } [
    { } [
        "hello" current-vocab create-word
        old-definitions get first adjoin
        "hello" (CREATE-C-TYPE) drop
        old-definitions get first cardinality
    ] with-parsing
] unit-test

! make-callback-type
{ "what-type" } [
    { } [
        void "what-type" f { } { } make-callback-type 2drop name>>
    ] with-parsing
] unit-test

{ 1 } [
    { } [
        "hello" current-vocab create-word
        old-definitions get first adjoin
        void "hello" f { } { } make-callback-type 3drop
        old-definitions get first cardinality
    ] with-parsing
] unit-test

! parse-enum-name
{ t } [
    { "ayae" } [ parse-enum-name new-definitions get first in? ] with-parsing
] unit-test

! validate-c-type-name
{ "Cannot define a C type “hello*” that ends with an asterisk (*)" } [
    [ "hello*" validate-c-type-name ] [ ] recover summary
] unit-test

>>

TYPEDEF: char char2

SYMBOL: not-c-type

CONSTANT: eleven 11

[
    "alien.parser.tests" use-vocab
    "alien.c-types" use-vocab

    [ int ] [ "int" parse-c-type ] unit-test
    [ { int 5 } ] [ "int[5]" parse-c-type ] unit-test
    [ { int 5 10 11 } ] [ "int[5][10][11]" parse-c-type ] unit-test
    [ { int 5 10 eleven } ] [ "int[5][10][eleven]" parse-c-type ] unit-test
    [ pointer: void ] [ "void*" parse-c-type ] unit-test
    [ pointer: int ] [ "int*" parse-c-type ] unit-test
    [ pointer: int* ] [ "int**" parse-c-type ] unit-test
    [ pointer: int** ] [ "int***" parse-c-type ] unit-test
    [ pointer: int*** ] [ "int****" parse-c-type ] unit-test
    [ { pointer: int 3 } ] [ "int*[3]" parse-c-type ] unit-test
    [ { pointer: void 3 } ] [ "void*[3]" parse-c-type ] unit-test
    [ pointer: { int 3 } ] [ "int[3]*" parse-c-type ] unit-test
    [ c-string ] [ "c-string" parse-c-type ] unit-test
    [ char2 ] [ "char2" parse-c-type ] unit-test
    [ pointer: char2 ] [ "char2*" parse-c-type ] unit-test

    [ "void[3]" parse-c-type ] must-fail
    [ "int[3" parse-c-type ] must-fail
    [ "int[3][4" parse-c-type ] must-fail
    [ "not-word" parse-c-type ] [ error>> no-word-error? ] must-fail-with
] with-file-vocabs

FUNCTION: void* alien-parser-function-effect-test ( int *arg1, float arg2 )

{ ( arg1 arg2 -- void* ) } [
    \ alien-parser-function-effect-test "declared-effect" word-prop
] unit-test

{ t } [ \ alien-parser-function-effect-test inline? ] unit-test

FUNCTION-ALIAS: (alien-parser-function-effect-test) void* alien-parser-function-effect-test ( int *arg1, float arg2 )

{ ( arg1 arg2 -- void* ) } [
    \ (alien-parser-function-effect-test) "declared-effect" word-prop
] unit-test

{ t } [ \ (alien-parser-function-effect-test) inline? ] unit-test

CALLBACK: void* alien-parser-callback-effect-test ( int *arg1 float arg2 )

{ ( arg1 arg2 -- void* ) } [
    \ alien-parser-callback-effect-test "callback-effect" word-prop
] unit-test

{ t } [ \ alien-parser-callback-effect-test inline? ] unit-test

! Reported by mnestic
TYPEDEF: int alien-parser-test-int ! reasonably unique name...

{ "OK!" } [
    [
        "USE: specialized-arrays SPECIALIZED-ARRAY: alien-parser-test-int" eval( -- )
        ! after restart, we end up here
        "OK!"
    ] [ :1 ] recover
] unit-test

! Redefinitions
{ } [
    [ C-TYPE: hi TYPEDEF: void* hi ] with-compilation-unit
] unit-test
