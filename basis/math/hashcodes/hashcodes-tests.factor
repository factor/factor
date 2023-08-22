! Copyright (C) 2013 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: arrays kernel grouping math math.hashcodes sequences
tools.test ;

{ t } [
    12 dup >bignum 12.0 12 0 complex boa 4array
    [ number-hashcode ] map all-equal?
] unit-test

{ t } [
    1.5 3/2 1.5 0 complex boa 3/2 0 complex boa 4array
    [ number-hashcode ] map all-equal?
] unit-test
