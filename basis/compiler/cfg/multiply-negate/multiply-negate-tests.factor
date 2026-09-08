USING: accessors compiler.cfg compiler.cfg.instructions
compiler.cfg.multiply-negate compiler.cfg.utilities compiler.test
cpu.architecture kernel kernel.private math math.private sequences tools.test ;
IN: compiler.cfg.multiply-negate.tests

: fused-insns ( insns -- insns' )
    insns>cfg [ fuse-multiply-negate ] keep entry>> instructions>> ;

{ t } [
    {
        T{ ##mul { dst 2 } { src1 0 } { src2 1 } }
        T{ ##neg { dst 3 } { src 2 } }
    } fused-insns last T{ ##mneg { dst 3 } { src1 0 } { src2 1 } } =
] unit-test

! Keep the multiplication when the product is independently used.
{ 0 } [
    {
        T{ ##mul { dst 2 } { src1 0 } { src2 1 } }
        T{ ##neg { dst 3 } { src 2 } }
        T{ ##add { dst 4 } { src1 2 } { src2 3 } }
    } fused-insns [ ##mneg? ] count
] unit-test

! The overflow-checking instruction must retain its check and branch.
{ 0 } [
    {
        T{ ##fixnum-mul { dst 2 } { src1 0 } { src2 1 } }
        T{ ##neg { dst 3 } { src 2 } }
    } fused-insns [ ##mneg? ] count
] unit-test

! This is a real frontend-to-register-allocation path, not only a manually
! constructed CFG. The original multiplication disappears in DCE.
{ 1 } [
    [ { fixnum fixnum } declare fixnum*fast -1 fixnum*fast ]
    [ ##mneg? ] count-insns
] unit-test
{ 0 } [
    [ { fixnum fixnum } declare fixnum*fast -1 fixnum*fast ]
    [ ##mul? ] count-insns
] unit-test

{ -42 } [ 6 7 [ { fixnum fixnum } declare fixnum*fast -1 fixnum*fast ] compile-call ] unit-test
{ 42 } [ -6 7 [ { fixnum fixnum } declare fixnum*fast -1 fixnum*fast ] compile-call ] unit-test
{ 0 } [ 0 -7 [ { fixnum fixnum } declare fixnum*fast -1 fixnum*fast ] compile-call ] unit-test
{ -49 } [ 7 [ { fixnum } declare dup fixnum*fast -1 fixnum*fast ] compile-call ] unit-test

USING: layouts locals ;

{ t } [
    most-negative-fixnum 1
    [ { fixnum fixnum } declare fixnum*fast -1 fixnum*fast ] compile-call
    most-negative-fixnum =
] unit-test
{ 2 } [
    most-positive-fixnum 2
    [ { fixnum fixnum } declare fixnum*fast -1 fixnum*fast ] compile-call
] unit-test
{ t } [
    most-positive-fixnum 2 * neg
    most-positive-fixnum 2 [ { fixnum fixnum } declare * neg ] compile-call =
] unit-test

:: shared-use-in-successor ( -- n )
    {
        T{ ##mul { dst 2 } { src1 0 } { src2 1 } }
        T{ ##neg { dst 3 } { src 2 } }
        T{ ##branch }
    } 0 insns>block :> first-block
    {
        T{ ##add { dst 4 } { src1 2 } { src2 3 } }
    } 1 insns>block :> second-block
    first-block second-block connect-bbs
    first-block block>cfg fuse-multiply-negate
    first-block instructions>> [ ##mneg? ] count ;

{ 0 } [ shared-use-in-successor ] unit-test
