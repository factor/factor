USING: accessors effects help help.markup help.syntax help.topics kernel
sequences tools.test words ;
IN: help.tests

[ 3 throw ] must-fail
{ } [ :help ] unit-test
{ } [ f print-topic ] unit-test

CONSTANT: documented-constant 42
HELP: documented-constant
{ $values { "answer" "the answer" } } ;

CONSTANT: undocumented-constant 42

{ { { $outputs { "answer" "the answer" } } } } [
    \ $outputs \ documented-constant word-help elements
] unit-test

{ t } [
    \ documented-constant article-title "( -- answer )" tail?
] unit-test

! Display names must not mutate the compiler's declared stack effect.
{ { "value" } } [ \ documented-constant stack-effect out>> ] unit-test
{ { { $outputs { "value" object } } } } [
    \ $outputs \ undocumented-constant word-help elements
] unit-test
