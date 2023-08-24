USING: tools.test concurrency.locks concurrency.count-downs
concurrency.messaging concurrency.mailboxes kernel
threads sequences calendar accessors ;
IN: concurrency.locks.tests

:: lock-test-0 ( -- v )
    V{ } clone :> v
    2 <count-down> :> c

    [
        yield
        1 v push
        yield
        2 v push
        c count-down
    ] "Lock test 1" spawn drop

    [
        yield
        3 v push
        yield
        4 v push
        c count-down
    ] "Lock test 2" spawn drop

    c await
    v ;

:: lock-test-1 ( -- v )
    V{ } clone :> v
    <lock> :> l
    2 <count-down> :> c

    [
        l [
            yield
            1 v push
            yield
            2 v push
        ] with-lock
        c count-down
    ] "Lock test 1" spawn drop

    [
        l [
            yield
            3 v push
            yield
            4 v push
        ] with-lock
        c count-down
    ] "Lock test 2" spawn drop

    c await
    v ;

{ V{ 1 3 2 4 } } [ lock-test-0 ] unit-test
{ V{ 1 2 3 4 } } [ lock-test-1 ] unit-test

{ 3 } [
    <reentrant-lock> dup [
        [
            3
        ] with-lock
    ] with-lock
] unit-test

[ <rw-lock> ] must-not-fail

{ } [ <rw-lock> [ ] with-read-lock ] unit-test

{ } [ <rw-lock> dup [ [ ] with-read-lock ] with-read-lock ] unit-test

{ } [ <rw-lock> [ ] with-write-lock ] unit-test

{ } [ <rw-lock> dup [ [ ] with-write-lock ] with-write-lock ] unit-test

{ } [ <rw-lock> dup [ [ ] with-read-lock ] with-write-lock ] unit-test

:: rw-lock-test-1 ( -- v )
    <rw-lock> :> l
    1 <count-down> :> c
    1 <count-down> :> c'
    4 <count-down> :> c''
    V{ } clone :> v

    [
        l [
            1 v push
            c count-down
            yield
            3 v push
        ] with-read-lock
        c'' count-down
    ] "R/W lock test 1" spawn drop

    [
        c await
        l [
            4 v push
            1 seconds sleep
            5 v push
        ] with-write-lock
        c'' count-down
    ] "R/W lock test 2" spawn drop

    [
        c await
        l [
            2 v push
            c' count-down
        ] with-read-lock
        c'' count-down
    ] "R/W lock test 4" spawn drop

    [
        c' await
        l [
            6 v push
        ] with-write-lock
        c'' count-down
    ] "R/W lock test 5" spawn drop

    c'' await
    v ;

{ V{ 1 2 3 4 5 6 } } [ rw-lock-test-1 ] unit-test

:: rw-lock-test-2 ( -- v )
    <rw-lock> :> l
    1 <count-down> :> c
    2 <count-down> :> c'
    V{ } clone :> v

    [
        l [
            1 v push
            c count-down
            1 seconds sleep
            2 v push
        ] with-write-lock
        c' count-down
    ] "R/W lock test 1" spawn drop

    [
        c await
        l [
            3 v push
        ] with-read-lock
        c' count-down
    ] "R/W lock test 2" spawn drop

    c' await
    v ;

{ V{ 1 2 3 } } [ rw-lock-test-2 ] unit-test

! Test lock timeouts
:: lock-timeout-test ( -- v )
    <lock> :> l

    [
        l [ 1 seconds sleep ] with-lock
    ] "Lock holder" spawn drop

    [
        l 1/10 seconds [ ] with-lock-timeout
    ] "Lock timeout-er" spawn-linked drop

    receive ;

[ lock-timeout-test ] [
    thread>> name>> "Lock timeout-er" =
] must-fail-with

[
    <rw-lock> dup [
        1 seconds [ ] with-write-lock-timeout
    ] with-read-lock
] must-fail

[
    <rw-lock> dup [
        dup [
            1 seconds [ ] with-write-lock-timeout
        ] with-read-lock
    ] with-write-lock
] must-fail

{ } [
    <rw-lock> dup [
        dup [
            1 seconds [ ] with-read-lock-timeout
        ] with-read-lock
    ] with-write-lock
] unit-test
