USING: math sequences classes growable tools.test kernel
layouts ;
IN: temporary

! erg found this one
[ fixnum ] [
    2 >bignum V{ } [ set-length ] keep length class
] unit-test

! overflow bugs
[ "hi" most-positive-fixnum 2 * 2 + V{ } clone set-nth ]
unit-test-fails

[ most-positive-fixnum 2 * 2 + { 1 } clone nth ]
unit-test-fails

[ most-positive-fixnum 2 * 2 + V{ } clone lengthen ]
unit-test-fails

[ most-positive-fixnum 2 * 2 + V{ } clone set-length ]
unit-test-fails

[ ] [
    10 V{ } [ set-length ] keep
    1/2 swap set-length
] unit-test
