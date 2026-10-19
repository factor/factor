! C++ native libm traps must not enter recompiled Factor FPC helper words.
! Run on an ordinarily optimized SystemZ image, then compare both VMs.
USING: compiler compiler.units continuations io kernel kernel.private math math.bitwise
math.floats.env math.functions math.libm memory sequences ;
IN: s390x.fp-signal-gc

: check-fp-trap ( error mask -- )
    [ dup 2 head { 64199 17 } assert= 2 swap nth ] dip
    bitand 0 > t assert= ;

[ { +fp-invalid-operation+ } [ -1.0 fsqrt drop ] with-fp-traps
  "invalid operation did not trap" throw ]
[ 1 check-fp-trap ] recover
gc

[ { +fp-underflow+ +fp-inexact+ } [ 2.0 -100000.0 ^ drop ] with-fp-traps
  "underflow did not trap" throw ]
[ 20 check-fp-trap ] recover
gc

: compiled-zero-divide ( a b -- c )
    { float float } declare
    { +fp-zero-divide+ } [ /f ] with-fp-traps ;
{ compiled-zero-divide } compile

[ 1.0 0.0 compiled-zero-divide drop
  "compiled division did not trap" throw ]
[ 8 check-fp-trap ] recover
gc
"S390X-FP-SIGNAL-GC-PASS" print flush
