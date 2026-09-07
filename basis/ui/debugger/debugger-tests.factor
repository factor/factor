USING: alien alien.c-types alien.syntax continuations effects kernel
namespaces sequences stack-checker tools.test ui ui.backend ui.debugger
vectors ;
IN: ui.debugger.tests

SINGLETON: test-alert-backend

M: test-alert-backend system-alert
    2drop t "alerts" get push ;

: invoke-error-alert ( -- )
    void { } cdecl [ "Callback error test" error-alert ] alien-callback
    void { } cdecl alien-indirect ;

! Ordinary UI errors still open an alert, but native callbacks only log.
{ 1 } [
    V{ } clone "alerts" set
    test-alert-backend ui-backend [
        "UI error test" error-alert
    ] with-variable
    "alerts" get length
] unit-test

{ 0 } [
    V{ } clone "alerts" set
    test-alert-backend ui-backend [
        invoke-error-alert
    ] with-variable
    "alerts" get length
] unit-test

! rethrow calls this hook with a non-returning stack effect.
{ t } [
    callback-error-hook get-global infer ( error -- * ) effect=
] unit-test
