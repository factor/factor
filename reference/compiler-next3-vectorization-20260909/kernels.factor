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

! The oracle uses arbitrary-precision addition and explicitly reduces to the
! signed fixnum width. It neither shares the unrolled body nor uses SIMD.
:: scalar-oracle ( x key increment -- y )
    x 12 [ key bitxor increment + ] times ;
