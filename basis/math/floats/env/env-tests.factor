USING: kernel math math.floats.env math.floats.env.private
math.functions math.libm sets sequences tools.test ;
IN: math.floats.env.tests

: set-default-fp-env ( -- )
    { } { } +round-nearest+ +denormal-keep+ set-fp-env ;

! In case the tests screw up the FP env because of bugs in math.floats.env
set-default-fp-env

[ t ] [
    [ 1.0 0.0 / drop ] collect-fp-exceptions
    { +fp-zero-divide+ } set= 
] unit-test

[ t ] [
    [ 1.0 3.0 / drop ] collect-fp-exceptions
    { +fp-inexact+ } set= 
] unit-test

[ t ] [
    [ 1.0e250 1.0e100 * drop ] collect-fp-exceptions
    +fp-overflow+ swap member?
] unit-test

[ t ] [
    [ 1.0e-250 1.0e-100 * drop ] collect-fp-exceptions
    +fp-underflow+ swap member?
] unit-test

[ t ] [
    [ 0.0 0.0 /f drop ] collect-fp-exceptions
    { +fp-invalid-operation+ } set= 
] unit-test

[
    HEX: 3fd5,5555,5555,5555
    HEX: 3fc9,9999,9999,999a
    HEX: bfc9,9999,9999,999a
    HEX: bfd5,5555,5555,5555
] [
    +round-nearest+ [
         1.0 3.0 /f double>bits
         1.0 5.0 /f double>bits
        -1.0 5.0 /f double>bits
        -1.0 3.0 /f double>bits
    ] with-rounding-mode
] unit-test

[
    HEX: 3fd5,5555,5555,5555
    HEX: 3fc9,9999,9999,9999
    HEX: bfc9,9999,9999,999a
    HEX: bfd5,5555,5555,5556
] [
    +round-down+ [
         1.0 3.0 /f double>bits
         1.0 5.0 /f double>bits
        -1.0 5.0 /f double>bits
        -1.0 3.0 /f double>bits
    ] with-rounding-mode
] unit-test

[
    HEX: 3fd5,5555,5555,5556
    HEX: 3fc9,9999,9999,999a
    HEX: bfc9,9999,9999,9999
    HEX: bfd5,5555,5555,5555
] [
    +round-up+ [
         1.0 3.0 /f double>bits
         1.0 5.0 /f double>bits
        -1.0 5.0 /f double>bits
        -1.0 3.0 /f double>bits
    ] with-rounding-mode
] unit-test

[
    HEX: 3fd5,5555,5555,5555
    HEX: 3fc9,9999,9999,9999
    HEX: bfc9,9999,9999,9999
    HEX: bfd5,5555,5555,5555
] [
    +round-zero+ [
         1.0 3.0 /f double>bits
         1.0 5.0 /f double>bits
        -1.0 5.0 /f double>bits
        -1.0 3.0 /f double>bits
    ] with-rounding-mode
] unit-test

! ensure rounding mode is restored to +round-nearest+
[
    HEX: 3fd5,5555,5555,5555
    HEX: 3fc9,9999,9999,999a
    HEX: bfc9,9999,9999,999a
    HEX: bfd5,5555,5555,5555
] [
     1.0 3.0 /f double>bits
     1.0 5.0 /f double>bits
    -1.0 5.0 /f double>bits
    -1.0 3.0 /f double>bits
] unit-test

[ { +fp-zero-divide+ }       [ 1.0 0.0 /f ] with-fp-traps ] must-fail
[ { +fp-inexact+ }           [ 1.0 3.0 /f ] with-fp-traps ] must-fail
[ { +fp-invalid-operation+ } [ -1.0 fsqrt ] with-fp-traps ] must-fail
[ { +fp-overflow+ }          [ 2.0  100,000.0 ^ ] with-fp-traps ] must-fail
[ { +fp-underflow+ }         [ 2.0 -100,000.0 ^ ] with-fp-traps ] must-fail

! Ensure traps get cleared
[ 1/0. ] [ 1.0 0.0 /f ] unit-test

! Ensure state is back to normal
[ +round-nearest+ ] [ rounding-mode ] unit-test
[ +denormal-keep+ ] [ denormal-mode ] unit-test
[ { } ] [ fp-traps ] unit-test

! In case the tests screw up the FP env because of bugs in math.floats.env
set-default-fp-env

