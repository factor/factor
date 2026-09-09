! Ordinary scalar integer mixing, with no SIMD type or intrinsic.
USING: kernel kernel.private locals math math.private sequences ;
IN: benchmark.scalar-mixing

:: twelve-rounds ( x key increment -- y )
    x key bitxor increment fixnum+fast key bitxor increment fixnum+fast
    key bitxor increment fixnum+fast key bitxor increment fixnum+fast
    key bitxor increment fixnum+fast key bitxor increment fixnum+fast
    key bitxor increment fixnum+fast key bitxor increment fixnum+fast
    key bitxor increment fixnum+fast key bitxor increment fixnum+fast
    key bitxor increment fixnum+fast key bitxor increment fixnum+fast ; inline

: mixing-pair ( x y key increment -- a b )
    { fixnum fixnum fixnum fixnum } declare
    [| x y key increment |
        x key increment twelve-rounds y key increment twelve-rounds
    ] call ;

! The oracle uses arbitrary-precision addition. Callers testing wrapping
! endpoints reduce its result to the signed fixnum width explicitly. It
! neither shares the unrolled body nor uses SIMD.
:: scalar-oracle ( x key increment -- y )
    x 12 [ key bitxor increment + ] times ;

USING: namespaces ;
SYMBOL: selected-mixing-kernel
\ mixing-pair selected-mixing-kernel set-global

! A mutable word handle prevents callers from inlining a previously compiled
! scalar copy. The benchmark installer recompiles this same target OFF/ON.
: invoke-mixing ( x y key increment -- a b )
    selected-mixing-kernel get execute( x y key increment -- a b ) ;
