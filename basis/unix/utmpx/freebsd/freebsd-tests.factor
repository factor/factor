USING: accessors alien.c-types alien.data classes.struct combinators kernel
layouts math system tools.test unix.ffi unix.utmpx ;
IN: unix.utmpx.freebsd.tests

cell 8 = [
{ 0 8 24 32 36 68 84 212 280 } [
    "ut_type" utmpx offset-of
    "ut_tv" utmpx offset-of
    "ut_id" utmpx offset-of
    "ut_pid" utmpx offset-of
    "ut_user" utmpx offset-of
    "ut_line" utmpx offset-of
    "ut_host" utmpx offset-of
    "__ut_spare" utmpx offset-of
    utmpx heap-size
] unit-test
] when

{ 1 2 3 4 7 8 } [
    BOOT_TIME OLD_TIME NEW_TIME USER_PROCESS DEAD_PROCESS SHUTDOWN_TIME
] unit-test

{ "" "" "" 42 4 "" } [
    utmpx new 42 >>ut_pid USER_PROCESS >>ut_type
    utmpx>utmpx-record
    { [ user>> ] [ id>> ] [ line>> ] [ pid>> ] [ type>> ] [ host>> ] } cleave
] unit-test
