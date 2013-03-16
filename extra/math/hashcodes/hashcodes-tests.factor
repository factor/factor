! Copyright (C) 2013 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: arrays kernel math sequences tools.test ;

IN: math.hashcodes

{ t } [
    12 dup >bignum 12.0 12 0 complex boa 4array
    [ number-hashcode 12 = ] all?
] unit-test

{ t } [
    1.5 3/2 1.5 0 complex boa 3/2 0 complex boa 4array
    [ number-hashcode 3458764513820540928 = ] all?
] unit-test
