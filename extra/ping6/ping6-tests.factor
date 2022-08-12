USING: continuations destructors io.sockets kernel math.order
ping system system-info tools.test ;

IN: ping6.tests

! { 5 1 } is xp
: test-ping? ( -- ? )
    os windows?
    os-version { 5 1 } after? and not ;

test-ping? [
    [ ] [ "::1" ping6 drop ] unit-test
    [ t ] [ "::1" alive6? ] unit-test
] when
