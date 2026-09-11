USING: accessors continuations destructors io.backend.unix
io.sockets kernel locals namespaces tools.test ;
QUALIFIED-WITH: unix.ffi unix
IN: io.backend.unix.cleanup-tests

TUPLE: failing-cancel-fd < fd ;
M: failing-cancel-fd cancel-operation drop "cancel failed" throw ;

! Closing an fd remains mandatory if cancellation itself fails.
{ t -1 } [
    [
      [let
        "/dev/null" 0 0 unix:open :> number
        failing-cancel-fd new-disposable number >>fd :> failing
        [ failing dispose ] [ "cancel failed" = ] must-fail-with
        failing disposed>>
        number f 0 unix:read
      ]
    ] with-destructors
] unit-test
