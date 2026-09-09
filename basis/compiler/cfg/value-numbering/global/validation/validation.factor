! Copyright (C) 2026 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
USING: compiler.units kernel locals math math.bitwise ranges
sequences stack-checker typed words ;
IN: compiler.cfg.value-numbering.global.validation

! Compile fresh wrappers for each flag setting. Both inputs are runtime
! values, and these inline bodies cannot call an old typed specialization.
TYPED:: gvn-branch-program ( x: fixnum flag: boolean -- y: fixnum )
    x 7 bitxor :> a
    flag [ a 3 bitand ] [ a 1 bitand ] if
    x 7 bitxor bitxor ; inline

TYPED:: gvn-loop-program ( x: fixnum n: fixnum -- y: fixnum )
    x 31 bitxor :> base
    0 :> total!
    n [| i |
        x 31 bitxor i bitxor total + total!
    ] each-integer
    total base bitxor ; inline

:: branch-answer ( x flag -- answer )
    x 7 bitxor dup flag 3 1 ? bitand bitxor ;

:: loop-answer ( x n -- answer )
    n <iota> [ x 31 bitxor bitxor ] map-sum
    x 31 bitxor bitxor ;

: fresh-compiled-word ( quot -- word )
    [ dup infer define-temp ] with-compilation-unit ;
