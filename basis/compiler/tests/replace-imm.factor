! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays kernel math sequences tools.test ;
IN: compiler.tests.replace-imm

! Immediate stores into stack slots beyond the signed unscaled
! addressing range clobbered the value scratch register on arm64.
: forty-fixnums ( -- a )
    1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20
    21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40
    40 narray ;

: forty-fs ( -- a )
    f f f f f f f f f f f f f f f f f f f f
    f f f f f f f f f f f f f f f f f f f f
    40 narray ;

{ t } [ forty-fixnums 40 <iota> [ 1 + ] map sequence= ] unit-test
{ t } [ forty-fs [ f eq? ] all? ] unit-test
