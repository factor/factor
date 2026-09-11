USING: accessors assocs calendar concurrency.promises continuations kernel
libc locals namespaces sequences threads tools.test unix.ffi
unix.process unix.signals unix.signals.private ;
FROM: unix.signals => signal ;
IN: unix.signals.tests

! Signal numbers are platform-specific, including the two user signals.
{ "SIGUSR1" } [ SIGUSR1 signal-name ] unit-test
{ "SIGUSR2" } [ SIGUSR2 signal-name ] unit-test
{ "SIGCHLD" } [ SIGCHLD signal-name ] unit-test
{ "SIGCONT" } [ SIGCONT signal-name ] unit-test
{ "SIGSTOP" } [ SIGSTOP signal-name ] unit-test
{ "SIGTSTP" } [ SIGTSTP signal-name ] unit-test
{ "SIGBUS" } [ SIGBUS signal-name ] unit-test
{ "SIGSYS" } [ SIGSYS signal-name ] unit-test
{ "SIGUSR1" } [ signal new SIGUSR1 >>n signal-name ] unit-test
{ f f f } [ -1 signal-name 0 signal-name 1000 signal-name ] unit-test

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
