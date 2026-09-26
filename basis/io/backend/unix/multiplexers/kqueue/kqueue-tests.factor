USING: accessors assocs continuations destructors io.backend.unix.multiplexers
io.backend.unix.multiplexers.kqueue kernel libc locals math namespaces sequences
tools.annotations tools.test unix unix.ffi unix.kqueue unix.process ;
IN: io.backend.unix.multiplexers.kqueue.tests

SYMBOL: signal-received?

{ t t } [
    [
        <kqueue-mx> &dispose
        f signal-received? set
        [ t signal-received? set ] SIGCHLD pick add-signal-callback
        [ getpid SIGCHLD kill io-error 1000000000 swap wait-for-events ] dip
        signal-received? get
    ] with-destructors
] unit-test

! Backends without signal support must keep the polling fallback.
{ f } [ [ ] SIGCHLD f add-signal-callback ] unit-test

SYMBOL: kevent-calls

: interrupted-kevent ( kq changes nchanges events nevents timeout -- n )
    3drop 3drop kevent-calls [ 1 + ] change EINTR set-errno -1 ;

! Keep real event-loop callbacks working while the syscall is annotated.
:: mock-kevent ( kq changes nchanges events nevents timeout original mock -- n )
    kq changes nchanges events nevents timeout
    kq -1234 = [ mock ] [ original ] if
    call( kq changes nchanges events nevents timeout -- n ) ;

! Replay would apply the same deletion twice. EINTR already applied changes.
{ 1 } [
    [
        \ kevent-func [ [ interrupted-kevent ] '[ _ _ mock-kevent ] ] annotate
        0 kevent-calls [
            42 EVFILT_READ EV_DELETE make-kevent kqueue-mx new -1234 >>fd
            register-kevent kevent-calls get
        ] with-variable
    ] [ \ kevent-func reset ] finally
] unit-test

: invalid-kevent ( kq changes nchanges events nevents timeout -- n )
    3drop 3drop EBADF set-errno -1 ;

:: failed-registration-keeps-callbacks ( -- ? )
    kqueue-mx new -1234 >>fd H{ } clone >>reads H{ } clone >>writes :> mx
    [ f 42 mx add-input-callback ] [ errno>> EBADF = ] must-fail-with
    mx reads>> assoc-empty? ;

{ t } [
    [
        \ kevent-func [ [ invalid-kevent ] '[ _ _ mock-kevent ] ] annotate
        failed-registration-keeps-callbacks
    ] [ \ kevent-func reset ] finally
] unit-test
