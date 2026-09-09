USING: arrays kernel kernel.private layouts locals math math.private
sequences tools.test ;
IN: compiler.tests.right-shifts

: reference-shift ( x n -- y ) fixnum-shift ;

: right-shift ( x n -- y )
    { fixnum fixnum } declare
    dup 0 <= [ shift ] [ drop ] if ;

:: right-shift-agrees? ( x n -- ? )
    x n reference-shift x n right-shift = ;

! Include zero, both signs, payload boundaries, and counts large enough
! to wrap a machine shift or overflow when negated without clamping.
{ t } [
    most-negative-fixnum most-positive-fixnum 2array
    { -257 -256 -255 -3 -2 -1 0 1 2 3 255 256 257 } append
    [
        201 <iota> [ neg ] map
        most-negative-fixnum suffix
        [ right-shift-agrees? ] with all?
    ] all?
] unit-test

{ 123 } [ 123 1 right-shift ] unit-test

! Unconstrained shifts must still handle positive counts and bignum results.
{ t } [ 1 fixnum-bits reference-shift bignum? ] unit-test
