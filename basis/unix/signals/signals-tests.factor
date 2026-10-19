USING: accessors assocs calendar concurrency.promises continuations kernel
arrays libc locals math math.floats.env math.parser math.private
namespaces sequences threads system tools.test unix.ffi
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

! Factor installs a real ignored-signal handler for SIGUSR2. Returning from
! it must preserve the interrupted floating-point controls, including rounding.
: signal-fp-controls ( -- controls )
    rounding-mode fp-traps denormal-mode 3array ;

: ignored-sigusr2-preserves-fp-controls? ( mode -- ? )
    [
        signal-fp-controls
        SIGUSR2 raise 0 assert=
        signal-fp-controls =
    ] with-rounding-mode ;

floating-point-supported? [
{ t } [ +round-nearest+ ignored-sigusr2-preserves-fp-controls? ] unit-test
{ t } [ +round-zero+ ignored-sigusr2-preserves-fp-controls? ] unit-test
+round-down+ rounding-mode-supported? [
    { t } [ +round-down+ ignored-sigusr2-preserves-fp-controls? ] unit-test
] when
+round-up+ rounding-mode-supported? [
    { t } [ +round-up+ ignored-sigusr2-preserves-fp-controls? ] unit-test
] when

! On NetBSD Alpha the old return path changed nearest to round-to-zero,
! making a runtime decimal parse one ULP too small after the ignored signal.
{ 0x3fc999999999999a 0x3fc999999999999a } [
    +round-nearest+ [
        "0.2" string>number double>bits
        SIGUSR2 raise 0 assert=
        "0.2" string>number double>bits
    ] with-rounding-mode
] unit-test

] when

{ 0 123 } [
    [ 123 set-errno SIGUSR2 raise errno ] preserve-errno
] unit-test
