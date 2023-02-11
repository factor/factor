! Copyright (C) 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: fry kernel math.functions random random.lagged-fibonacci
sequences tools.test specialized-arrays alien.c-types ;
SPECIALIZED-ARRAY: double
IN: random.lagged-fibonacci.tests

{ t } [
    3 <lagged-fibonacci> [
        1000 [ random-float ] double-array{ } replicate-as
        999 swap nth 0.860072135925293 -.01 ~
    ] with-random
] unit-test

{ t } [
    3 <lagged-fibonacci> [
        [
            1000 [ random-float ] double-array{ } replicate-as
        ] with-random
    ] [
        3 seed-random [
            1000 [ random-float ] double-array{ } replicate-as
        ] with-random =
    ] bi
] unit-test
