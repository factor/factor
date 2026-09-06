! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays kernel math memory sequences strings tools.test ;
IN: compiler.tests.pic-churn

! Exercise every inline-cache transition and compact the code heap between
! misses, including while a PIC is still installed. Debug/PIC_FREE_GUARD VMs
! additionally prove that eager reclamation never selects a PIC represented by
! a live callstack frame.
GENERIC: churn ( obj -- n )

M: fixnum churn drop 0 ;
M: float churn drop 1 ;
M: string churn drop 2 ;
M: array churn drop 3 ;
M: f churn drop 4 ;

: churn-tail-site ( obj -- n ) churn ;

: churn-call-site ( obj -- n ) churn 10 + ;

{ { 0 1 2 3 4 } { 10 11 12 13 14 } } [
    { 1 1.0 "x" { } f } [ churn-tail-site compact-gc ] map
    { 1 1.0 "x" { } f } [ churn-call-site compact-gc ] map
] unit-test
