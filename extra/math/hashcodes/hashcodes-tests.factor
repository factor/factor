! Copyright (C) 2013 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: kernel sequences tools.test ;

IN: math.hashcodes

{ t } [
    { 12 12.0 C{ 12 0 } }
    [ number-hashcode 12 = ] all?
] unit-test

{ t } [
    { 1.5 3/2 C{ 1.5 0 } C{ 3/2 0 } }
    [ number-hashcode 3458764513820540928 = ] all?
] unit-test
