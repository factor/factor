USING: alien.c-types classes.struct kernel system tools.test
unix.ffi ;
IN: unix.ffi.linux.tests

{ 16 4 } [ sockaddr-in heap-size sockaddr-in c-type-align ] unit-test
{ 4096 4096 9 } [ MAXPATHLEN PATH_MAX SO_KEEPALIVE ] unit-test

cpu x86? [
    { 384 4 } [ utmpx heap-size utmpx c-type-align ] unit-test
    { 340 348 364 } [
        "ut_tv" utmpx offset-of
        "ut_addr_v6" utmpx offset-of
        "__unused" utmpx offset-of
    ] unit-test
    { 8 } [ utmpx-timeval heap-size ] unit-test
] when
