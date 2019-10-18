USING: classes kernel layouts math sequences tools.test ;

! erg found this one
{ fixnum } [
    2 >bignum V{ } [ set-length ] keep length class-of
] unit-test

! overflow bugs
[ "hi" most-positive-fixnum 2 * 2 + V{ } clone set-nth ]
must-fail

[ most-positive-fixnum 2 * 2 + { 1 } clone nth ]
must-fail

[ most-positive-fixnum 2 * 2 + V{ } clone lengthen ]
must-fail

[ most-positive-fixnum 2 * 2 + V{ } clone set-length ]
must-fail

[
    10 V{ } [ set-length ] keep
    0.5 swap set-length
] must-fail
