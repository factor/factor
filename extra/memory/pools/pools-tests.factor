! Copyright (C) 2009 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel memory.pools tools.test ;
IN: memory.pools.tests

TUPLE: foo x ;

{ 1 } [
    foo 2 foo <pool> set-class-pool

    foo new-from-pool drop
    foo class-pool pool-size
] unit-test

{ T{ foo } T{ foo } f } [
    foo 2 foo <pool> set-class-pool

    foo new-from-pool
    foo new-from-pool
    foo new-from-pool
] unit-test

{ f } [
    foo 2 foo <pool> set-class-pool

    foo new-from-pool
    foo new-from-pool
    eq?
] unit-test
