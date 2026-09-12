USING: concurrency.messaging continuations kernel
logging.insomniac.private namespaces threads tools.test ;
IN: logging.insomniac.tests

! Exercise rotation without sending mail or rotating the real log directory.
{ "report failed" { "rotate-logs" } } [
    self "log-server" [
        [ [ "report failed" throw ] with-log-rotation ] [ ] recover
        receive
    ] with-variable
] unit-test

{ 42 { "rotate-logs" } } [
    self "log-server" [
        [ 42 ] with-log-rotation receive
    ] with-variable
] unit-test
