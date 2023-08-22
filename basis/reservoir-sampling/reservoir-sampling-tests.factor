! Copyright (C) 2020 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors kernel random random.mersenne-twister
reservoir-sampling tools.test ;
IN: reservoir-sampling.tests

{
    T{ reservoir-sampler
        { iteration 11 }
        { k 4 }
        { sampled V{ 1 2 1005 1004 } }
    }
} [
    123 <mersenne-twister> [
        4 <reservoir-sampler>
        V{ 1 2 3 4 } clone >>sampled
        4 >>iteration
        1001 over reservoir-sample
        1002 over reservoir-sample
        1003 over reservoir-sample
        1004 over reservoir-sample
        1005 over reservoir-sample
        1006 over reservoir-sample
        1007 over reservoir-sample
    ] with-random
] unit-test

