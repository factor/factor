USING: accessors arrays generic generic.single growable kernel math
namespaces sequences strings tools.test vectors words ;
IN: generic.hook.tests

SYMBOL: my-var
HOOK: my-hook my-var ( -- x )

M: integer my-hook "an integer" ;
M: string my-hook "a string" ;

{ "an integer" } [ 3 my-var set my-hook ] unit-test
{ "a string" } [ my-hook my-var set my-hook ] unit-test
[ 1.0 my-var set my-hook ] [
    dup no-method? [
        [ object>> double>bits 0x3ff0000000000000 = ]
        [ generic>> \ my-hook eq? ] bi and
    ] [ drop f ] if
] must-fail-with

HOOK: call-next-hooker my-var ( -- x )

M: sequence call-next-hooker "sequence" ;

M: array call-next-hooker call-next-method "array " prepend ;

M: vector call-next-hooker call-next-method "vector " prepend ;

M: growable call-next-hooker call-next-method "growable " prepend ;

{ "vector growable sequence" } [
    V{ } my-var [ call-next-hooker ] with-variable
] unit-test

{ t } [
    { } \ nth effective-method nip M\ sequence nth eq?
] unit-test

{ t } [
    \ + \ nth effective-method nip dup \ nth "default-method" word-prop eq? and
] unit-test
