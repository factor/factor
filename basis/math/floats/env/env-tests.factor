USING: kernel math math.floats.env math.floats.env.private
math.functions math.libm sets tools.test ;
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
    [ 2.0 100,000.0 ^ drop ] collect-fp-exceptions
    { +fp-inexact+ +fp-overflow+ } set= 
] unit-test

[ t ] [
    [ 2.0 -100,000.0 ^ drop ] collect-fp-exceptions
    { +fp-inexact+ +fp-underflow+ } set= 
] unit-test

[ t ] [
    [ -1.0 fsqrt drop ] collect-fp-exceptions
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

[
    HEX: 0000,0000,0000,07e8
] [
    +denormal-keep+ [
        10.0 -320.0 ^ double>bits
    ] with-denormal-mode
] unit-test

[
    HEX: 0000,0000,0000,0000
] [
    +denormal-flush+ [
        10.0 -320.0 ^ double>bits
    ] with-denormal-mode
] unit-test

! ensure denormal mode is restored to +denormal-keep+
[
    HEX: 0000,0000,0000,07e8
] [
    +denormal-keep+ [
        10.0 -320.0 ^ double>bits
    ] with-denormal-mode
] unit-test

[ { +fp-zero-divide+ }       [ 1.0 0.0 /f ] with-fp-traps ] must-fail
[ { +fp-inexact+ }           [ 1.0 3.0 /f ] with-fp-traps ] must-fail
[ { +fp-invalid-operation+ } [ -1.0 fsqrt ] with-fp-traps ] must-fail
[ { +fp-overflow+ }          [ 2.0  100,000.0 ^ ] with-fp-traps ] must-fail
[ { +fp-underflow+ }         [ 2.0 -100,000.0 ^ ] with-fp-traps ] must-fail

! Ensure traps get cleared
[ 1/0. ] [ 1.0 0.0 /f ] unit-test

! In case the tests screw up the FP env because of bugs in math.floats.env
set-default-fp-env

