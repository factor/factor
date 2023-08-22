! Copyright (C) 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.data arrays kernel random random.cmwc
sequences specialized-arrays tools.test ;
SPECIALIZED-ARRAY: uint
IN: random.cmwc.tests

{ } [
    cmwc-4096 [
        random-32 drop
    ] with-random
] unit-test

{
{
    4294604858
    4294948512
    4294929730
    4294910948
    4294892166
    4294873384
    4294854602
    4294835820
    4294817038
    4294798256
}
} [
    cmwc-4096
    4096 <iota> uint >c-array 362436 <cmwc-seed> seed-random [
        10 [ random-32 ] replicate
    ] with-random
] unit-test

{ t } [
    cmwc-4096 [
        4096 <iota> uint >c-array 362436 <cmwc-seed> seed-random [
            10 [ random-32 ] replicate
        ] with-random
    ] [
        4096 <iota> uint >c-array 362436 <cmwc-seed> seed-random [
            10 [ random-32 ] replicate
        ] with-random
    ] bi =
] unit-test
