! (c)2009 Joe Groff bsd license
USING: kernel pools tools.test ;
IN: pools.tests

TUPLE: foo x ;
POOL: foo 2

[ 1 ] [
    foo class-pool pool-empty 
    foo new-from-pool drop
    foo class-pool pool-free-size
] unit-test

[ T{ foo } T{ foo } f ] [
    foo class-pool pool-empty 
    foo new-from-pool
    foo new-from-pool
    foo new-from-pool
] unit-test

[ f ] [
    foo class-pool pool-empty 
    foo new-from-pool
    foo new-from-pool
    eq?
] unit-test
