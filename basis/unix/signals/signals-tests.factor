USING: assocs calendar concurrency.promises continuations kernel
libc locals namespaces sequences threads tools.test unix.ffi
unix.signals unix.signals.private ;
IN: unix.signals.tests

:: test-sigusr1 ( delay -- received? registered? )
    <promise> :> received
    [ delay sleep t received fulfill ] :> handler
    handler SIGUSR1 add-signal-handler
    [
        SIGUSR1 raise 0 assert=
        received 10 seconds ?promise-timeout
    ] [ handler SIGUSR1 remove-signal-handler ] finally
    handler SIGUSR1 signal-handlers get-global at member? ;

! Wait for the handler itself, rather than assuming delivery within a sleep.
{ t f } [ 0 milliseconds test-sigusr1 ] unit-test

! Handler scheduling can exceed the old one-second sleep under load (#2259).
{ t f } [ 1250 milliseconds test-sigusr1 ] unit-test
