USING: continuations destructors io.sockets kernel math.order
ping system system-info tools.test ;
IN: ping.tests

! { 5 1 } is xp
: test-ping? ( -- ? )
    os windows?
    os-version { 5 1 } after? and not ;

test-ping? [
    [ "localhost" ping ] must-not-fail
    [ t ] [ "localhost" alive? ] unit-test
    [ t ] [ "127.0.0.1" alive? ] unit-test
    [ f ] [ "0.0.0.0" alive? ] unit-test
] when
