! Copyright (C) 2009 Jose Antonio Ortega Ruiz.
! See http://factorcode.org/license.txt for BSD license.
USING: continuations fuel fuel.eval io.streams.string kernel math
namespaces random.data sequences strings tools.test ;
IN: fuel.eval.tests

! pop-restarts
{ V{ "um" } } [
    fuel-eval-non-restartable V{ } clone restarts set-global
    V{ "um" } pop-restarts
    restarts get-global
    V{ } clone restarts set-global
] unit-test

! push-status
{ 1 } [
    V{ } clone [ status-stack set-global ] keep push-status
    length
    pop-status
] unit-test

! Make sure prettyprint doesn't limit output.

{ t } [
    1000 random-string eval-result set-global
    [ send-retort ] with-string-writer length 1000 >
    f eval-result set-global
] unit-test

{
    "(nil \"IN: kernel PRIMITIVE: dup ( x -- x x )\" \"\")\n<~FUEL~>\n"
} [
    [
        V{ "\"dup\"" "fuel-word-synopsis" } "scratchpad" V{ } fuel-eval-in-context
    ] with-string-writer
    f eval-result set-global
] unit-test
