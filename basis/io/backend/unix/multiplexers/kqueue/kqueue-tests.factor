USING: accessors assocs continuations io.backend.unix.multiplexers
io.backend.unix.multiplexers.kqueue kernel libc locals math namespaces sequences
tools.annotations tools.test unix unix.kqueue ;
IN: io.backend.unix.multiplexers.kqueue.tests

SYMBOL: kevent-calls

: interrupted-kevent ( kq changes nchanges events nevents timeout -- n )
    3drop 3drop kevent-calls [ 1 + ] change EINTR set-errno -1 ;

! Replay would apply the same deletion twice. EINTR already applied changes.
{ 1 } [
    [
        \ kevent-func [ drop [ interrupted-kevent ] ] annotate
        0 kevent-calls [
            42 EVFILT_READ EV_DELETE make-kevent kqueue-mx new 9 >>fd
            register-kevent kevent-calls get
        ] with-variable
    ] [ \ kevent-func reset ] finally
] unit-test

: invalid-kevent ( kq changes nchanges events nevents timeout -- n )
    3drop 3drop EBADF set-errno -1 ;

:: failed-registration-keeps-callbacks ( -- ? )
    kqueue-mx new H{ } clone >>reads H{ } clone >>writes :> mx
    [ f 42 mx add-input-callback ] [ errno>> EBADF = ] must-fail-with
    mx reads>> assoc-empty? ;

{ t } [
    [
        \ kevent-func [ drop [ invalid-kevent ] ] annotate
        failed-registration-keeps-callbacks
    ] [ \ kevent-func reset ] finally
] unit-test
