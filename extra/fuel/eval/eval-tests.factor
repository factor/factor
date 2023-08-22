! Copyright (C) 2009 Jose Antonio Ortega Ruiz.
! See https://factorcode.org/license.txt for BSD license.
USING: continuations fuel fuel.eval io.streams.string kernel math
namespaces random.data sequences tools.test vocabs.parser ;

! pop-restarts
{ V{ "um" } } [
    fuel-eval-non-restartable V{ } clone restarts set-global
    V{ "um" } pop-restarts
    restarts get-global
    V{ } clone restarts set-global
] unit-test

! push-status
{ 1 } [
    V{ } clone [ restarts-stack set-global ] keep push-status
    length
    pop-status
] unit-test

! Make sure prettyprint doesn't limit output.
{ t } [
    f 1000 random-string ""
    [ send-retort ] with-string-writer length 1000 >
] unit-test

! eval-in-context
{
    "(nil \"IN: kernel PRIMITIVE: dup ( x -- x x )\" \"\")\n<~FUEL~>\n"
} [
    [
        [
            V{ "\"dup\"" "fuel-word-synopsis" } "scratchpad"
            V{ "fuel" "kernel" "syntax" } eval-in-context
        ] with-string-writer
    ] with-manifest
] unit-test

{
    "(nil \"IN: http.server : <500> ( error -- response )\" \"\")\n<~FUEL~>\n"
} [
    USE: http.server
    [
        [
            V{ "\"<500>\"" "fuel-word-synopsis" }
            "http.server"
            V{ "fuel" "kernel" "syntax" } eval-in-context
        ] with-string-writer
    ] with-manifest
] unit-test

{
    "(nil 9 \"\")\n<~FUEL~>\n"
} [
    [
        { "3 sq" } "hi99"
        { "math" "kernel" } eval-in-context
    ] with-string-writer
] unit-test
