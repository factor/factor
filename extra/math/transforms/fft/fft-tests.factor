USING: kernel math math.functions math.transforms.fft
math.transforms.fft.private math.vectors sequences tools.test
vectors ;
IN: math.transforms.fft.tests

! even lengths

{ t } [
    { C{ 10 0 } C{ -2 2 } C{ -2 0 } C{ -2 -2 } }
    { 1 2 3 4 } fft 1e-12 v~
] unit-test

{ t } [
    { C{ 2+1/2 0 } C{ -1/2 -1/2 } C{ -1/2 0 } C{ -1/2 1/2 } }
    { 1 2 3 4 } ifft 1e-12 v~
] unit-test

! odd lengths

{ t } [
    { C{ 5 0 } C{ -1 0 } C{ -1 0 } }
    { 1 2 2 } fft 1e-12 v~
] unit-test

{ t } [
    { C{ 1+2/3 0 } C{ -1/3 0 } C{ -1/3 0 } }
    { 1 2 2 } ifft 1e-12 v~
] unit-test

{ t } [
    { C{ 0.05 0.0 } C{ 0.05 0.0 } C{ 0.05 0.0 } C{ 0.05 0.0 } }
    { 0.1 0.1 0.1 0.1 } { 0.2 0.1 0.1 0.1 } correlate 1e-12 v~
] unit-test

! Exercise odd subproblems at different recursion depths, with complex input.
: fft-test-input ( n -- seq )
    <iota> [ dup 0.17 * sin swap 0.31 * cos rect> ] map ;

{ t } [
    { 1 2 3 6 10 12 18 30 32 64 100 1000 } [
        fft-test-input [ fft ] [ f (slow-fft) ] bi 1e-8 v~
    ] all?
] unit-test

{ t } [
    { 1 2 3 6 10 12 18 30 32 64 100 1000 } [
        fft-test-input [ ifft ] [ t (slow-fft) ] bi 1e-8 v~
    ] all?
] unit-test

{ t } [
    { 1 2 3 6 10 12 18 30 32 64 100 1000 } [
        fft-test-input dup fft ifft 1e-8 v~
    ] all?
] unit-test

! Preserve the input and the power-of-two vector result type.
{ t } [
    12 fft-test-input dup clone [ dup fft drop ] dip =
] unit-test

{ t } [ 16 fft-test-input >vector fft vector? ] unit-test

[ { } fft ] [ not-enough-data? ] must-fail-with
[ { } ifft ] [ not-enough-data? ] must-fail-with
