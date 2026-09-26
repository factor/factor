USING: accessors continuations destructors io.backend io.launcher
io.launcher.private kernel locals math namespaces tools.test ;
IN: io.launcher.tests

SINGLETON: test-process-backend
SYMBOL: monitor-disposals
SYMBOL: monitor-fails?

TUPLE: test-monitor < disposable ;
M: test-monitor dispose* drop monitor-disposals [ 1 + ] change ;

M: test-process-backend (monitor-process)
    drop monitor-fails? get [ "registration failed" throw ] when
    test-monitor new-disposable ;

! Registration is idempotent; reaping releases the monitor exactly once.
{ t t 1 f } [
    test-process-backend io-backend [
        0 monitor-disposals [ [let
            <process> :> process
            process ensure-process-monitor
            process ensure-process-monitor
            process dispose-process-monitor
            process dispose-process-monitor
            monitor-disposals get process exit-monitor>>
        ]
        ] with-variable
    ] with-variable
] unit-test

! A failed registration must leave the child eligible for polling.
{ f f } [
    test-process-backend io-backend [
        t monitor-fails? [
            <process> dup ensure-process-monitor swap exit-monitor>>
        ] with-variable
    ] with-variable
] unit-test
