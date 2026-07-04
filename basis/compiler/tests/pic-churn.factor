! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays kernel math memory sequences strings tools.test ;
IN: compiler.tests.pic-churn

! Growing an inline cache frees the previous PIC eagerly, so
! dispatching through every cache size while compacting the code
! heap catches a PIC freed while still reachable.
GENERIC: churn ( obj -- n )

M: fixnum churn drop 0 ;
M: float churn drop 1 ;
M: string churn drop 2 ;
M: array churn drop 3 ;
M: f churn drop 4 ;

: churn-site ( obj -- n ) churn ;

{ t } [
    100 <iota> [
        drop { 1 1.0 "x" { } f } [ churn-site ] map
        compact-gc { 0 1 2 3 4 } =
    ] all?
] unit-test
