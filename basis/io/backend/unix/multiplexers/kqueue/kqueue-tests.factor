USING: accessors assocs destructors io.backend.unix io.backend.unix.multiplexers
io.backend.unix.multiplexers.kqueue io.sockets kernel libc locals namespaces sequences
tools.test unix unix.ffi unix.kqueue unix.process ;
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

! Exercise the real kernel registration and deletion paths.
{ 1 t } [
    [
      [let
        <kqueue-mx> &dispose :> mx
        "127.0.0.1" 0 <inet4> <datagram> &dispose handle>> handle-fd :> fd
        f fd mx add-input-callback
        fd mx remove-input-callbacks length
        mx reads>> assoc-empty?
      ]
    ] with-destructors
] unit-test

! A failed kernel registration must not add a callback to either table.
{ t t } [
    [let
        kqueue-mx new -1 >>fd H{ } clone >>reads H{ } clone >>writes :> mx
        [ f 42 mx add-input-callback ] [ errno>> EBADF = ] must-fail-with
        [ f 42 mx add-output-callback ] [ errno>> EBADF = ] must-fail-with
        mx [ reads>> assoc-empty? ] [ writes>> assoc-empty? ] bi
    ]
] unit-test
