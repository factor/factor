USING: kernel math math.floats.env math.floats.env.private
math.functions math.libm sequences tools.test locals
compiler.units kernel.private fry compiler math.private words
system ;
IN: math.floats.env.tests

: set-default-fp-env ( -- )
    { } { } +round-nearest+ +denormal-keep+ set-fp-env ;

! In case the tests screw up the FP env because of bugs in math.floats.env
set-default-fp-env

: test-fp-exception ( exception inputs quot -- quot' )
    '[ _ [ @ @ ] collect-fp-exceptions nip member? ] ;

: test-fp-exception-compiled ( exception inputs quot -- quot' )
    '[ _ @ [ _ collect-fp-exceptions ] compile-call nip member? ] ;

[ t ] +fp-zero-divide+ [ 1.0 0.0 ] [ /f ] test-fp-exception unit-test
[ t ] +fp-inexact+ [ 1.0 3.0 ] [ /f ] test-fp-exception unit-test
[ t ] +fp-overflow+ [ 1.0e250 1.0e100 ] [ * ] test-fp-exception unit-test
[ t ] +fp-underflow+ [ 1.0e-250 1.0e-100 ] [ * ] test-fp-exception unit-test
[ t ] +fp-overflow+ [ 2.0 100,000.0 ] [ fpow ] test-fp-exception unit-test
[ t ] +fp-invalid-operation+ [ 0.0 0.0 ] [ /f ] test-fp-exception unit-test
[ t ] +fp-invalid-operation+ [ -1.0 ] [ fsqrt ] test-fp-exception unit-test

[ t ] +fp-zero-divide+ [ 1.0 0.0 ] [ /f ] test-fp-exception-compiled unit-test
[ t ] +fp-inexact+ [ 1.0 3.0 ] [ /f ] test-fp-exception-compiled unit-test
[ t ] +fp-overflow+ [ 1.0e250 1.0e100 ] [ * ] test-fp-exception-compiled unit-test
[ t ] +fp-underflow+ [ 1.0e-250 1.0e-100 ] [ * ] test-fp-exception-compiled unit-test
[ t ] +fp-overflow+ [ 2.0 100,000.0 ] [ fpow ] test-fp-exception-compiled unit-test

! No underflow on Linux with this test, just inexact. Reported as an Ubuntu bug:
! https://bugs.launchpad.net/ubuntu/+source/glibc/+bug/429113
os linux? cpu x86.64? and [
    [ t ] +fp-underflow+ [ 2.0 -100,000.0 ] [ fpow ] test-fp-exception unit-test
    [ t ] +fp-underflow+ [ 2.0 -100,000.0 ] [ fpow ] test-fp-exception-compiled unit-test
] unless

[ t ] +fp-invalid-operation+ [ 0.0 0.0 ] [ /f ] test-fp-exception-compiled unit-test
[ t ] +fp-invalid-operation+ [ -1.0 ] [ fsqrt ] test-fp-exception-compiled unit-test

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

: test-traps ( traps inputs quot -- quot' )
    append '[ _ _ with-fp-traps ] ;

: test-traps-compiled ( traps inputs quot -- quot' )
    swapd '[ @ [ _ _ with-fp-traps ] compile-call ] ;

{ +fp-zero-divide+ } [ 1.0 0.0 ] [ /f ] test-traps must-fail
{ +fp-inexact+ } [ 1.0 3.0 ] [ /f ] test-traps must-fail
{ +fp-invalid-operation+ } [ -1.0 ] [ fsqrt ] test-traps must-fail
{ +fp-overflow+ } [ 2.0 ] [ 100,000.0 ^ ] test-traps must-fail
{ +fp-underflow+ +fp-inexact+ } [ 2.0 ] [ -100,000.0 ^ ] test-traps must-fail

{ +fp-zero-divide+ } [ 1.0 0.0 ] [ /f ] test-traps-compiled must-fail
{ +fp-inexact+ } [ 1.0 3.0 ] [ /f ] test-traps-compiled must-fail
{ +fp-invalid-operation+ } [ -1.0 ] [ fsqrt ] test-traps-compiled must-fail
{ +fp-overflow+ } [ 2.0 ] [ 100,000.0 ^ ] test-traps-compiled must-fail
{ +fp-underflow+ +fp-inexact+ } [ 2.0 ] [ -100,000.0 ^ ] test-traps-compiled must-fail

! Ensure ordered comparisons raise traps
:: test-comparison-quot ( word -- quot )
    [
        { float float } declare
        { +fp-invalid-operation+ } [ word execute ] with-fp-traps
    ] ;

: test-comparison ( inputs word -- quot )
    test-comparison-quot append ;

: test-comparison-compiled ( inputs word -- quot )
    test-comparison-quot '[ @ _ compile-call ] ;

\ float< "intrinsic" word-prop [
    [ 0/0. -15.0 ] \ < test-comparison must-fail
    [ 0/0. -15.0 ] \ < test-comparison-compiled must-fail
    [ -15.0 0/0. ] \ < test-comparison must-fail
    [ -15.0 0/0. ] \ < test-comparison-compiled must-fail
    [ 0/0. -15.0 ] \ <= test-comparison must-fail
    [ 0/0. -15.0 ] \ <= test-comparison-compiled must-fail
    [ -15.0 0/0. ] \ <= test-comparison must-fail
    [ -15.0 0/0. ] \ <= test-comparison-compiled must-fail
    [ 0/0. -15.0 ] \ > test-comparison must-fail
    [ 0/0. -15.0 ] \ > test-comparison-compiled must-fail
    [ -15.0 0/0. ] \ > test-comparison must-fail
    [ -15.0 0/0. ] \ > test-comparison-compiled must-fail
    [ 0/0. -15.0 ] \ >= test-comparison must-fail
    [ 0/0. -15.0 ] \ >= test-comparison-compiled must-fail
    [ -15.0 0/0. ] \ >= test-comparison must-fail
    [ -15.0 0/0. ] \ >= test-comparison-compiled must-fail

    [ f ] [ 0/0. -15.0 ] \ u< test-comparison unit-test
    [ f ] [ 0/0. -15.0 ] \ u< test-comparison-compiled unit-test
    [ f ] [ -15.0 0/0. ] \ u< test-comparison unit-test
    [ f ] [ -15.0 0/0. ] \ u< test-comparison-compiled unit-test
    [ f ] [ 0/0. -15.0 ] \ u<= test-comparison unit-test
    [ f ] [ 0/0. -15.0 ] \ u<= test-comparison-compiled unit-test
    [ f ] [ -15.0 0/0. ] \ u<= test-comparison unit-test
    [ f ] [ -15.0 0/0. ] \ u<= test-comparison-compiled unit-test
    [ f ] [ 0/0. -15.0 ] \ u> test-comparison unit-test
    [ f ] [ 0/0. -15.0 ] \ u> test-comparison-compiled unit-test
    [ f ] [ -15.0 0/0. ] \ u> test-comparison unit-test
    [ f ] [ -15.0 0/0. ] \ u> test-comparison-compiled unit-test
    [ f ] [ 0/0. -15.0 ] \ u>= test-comparison unit-test
    [ f ] [ 0/0. -15.0 ] \ u>= test-comparison-compiled unit-test
    [ f ] [ -15.0 0/0. ] \ u>= test-comparison unit-test
    [ f ] [ -15.0 0/0. ] \ u>= test-comparison-compiled unit-test
] when

! Ensure traps get cleared
[ 1/0. ] [ 1.0 0.0 /f ] unit-test

! Ensure state is back to normal
[ +round-nearest+ ] [ rounding-mode ] unit-test
[ +denormal-keep+ ] [ denormal-mode ] unit-test
[ { } ] [ fp-traps ] unit-test

! In case the tests screw up the FP env because of bugs in math.floats.env
set-default-fp-env

