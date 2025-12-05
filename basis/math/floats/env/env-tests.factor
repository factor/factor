USING: kernel math math.floats.env math.floats.env.private
math.functions math.libm literals sequences tools.test locals
compiler.units kernel.private fry compiler.test math.private
words system memory kernel.private ;
IN: math.floats.env.tests

: set-default-fp-env ( -- )
    { } { } +round-nearest+ +denormal-keep+ set-fp-env ;

! In case the tests screw up the FP env because of bugs in math.floats.env
set-default-fp-env

: test-fp-exception ( exception inputs quot -- quot' )
    '[ _ [ @ @ ] collect-fp-exceptions nip member? ] ;

: test-fp-exception-compiled ( exception inputs quot -- quot' )
    '[ _ @ [ _ collect-fp-exceptions ] compile-call nip member? ] ;

{ t } +fp-zero-divide+ [ 1.0 0.0 ] [ /f ] test-fp-exception unit-test
{ t } +fp-inexact+ [ 1.0 3.0 ] [ /f ] test-fp-exception unit-test
{ t } +fp-overflow+ [ 1.0e250 1.0e100 ] [ * ] test-fp-exception unit-test
{ t } +fp-underflow+ [ 1.0e-250 1.0e-100 ] [ * ] test-fp-exception unit-test
{ t } +fp-overflow+ [ 2.0 100,000.0 ] [ fpow ] test-fp-exception unit-test
{ t } +fp-invalid-operation+ [ 0.0 0.0 ] [ /f ] test-fp-exception unit-test
{ t } +fp-invalid-operation+ [ -1.0 ] [ fsqrt ] test-fp-exception unit-test

{ t } +fp-zero-divide+ [ 1.0 0.0 ] [ /f ] test-fp-exception-compiled unit-test
{ t } +fp-inexact+ [ 1.0 3.0 ] [ /f ] test-fp-exception-compiled unit-test
{ t } +fp-overflow+ [ 1.0e250 1.0e100 ] [ * ] test-fp-exception-compiled unit-test
{ t } +fp-underflow+ [ 1.0e-250 1.0e-100 ] [ * ] test-fp-exception-compiled unit-test
{ t } +fp-overflow+ [ 2.0 100,000.0 ] [ fpow ] test-fp-exception-compiled unit-test
{ t } +fp-invalid-operation+ [ 2.0 0/0. 1.0e-9 ] [ ~ ] test-fp-exception-compiled unit-test

! XXX: investigate why this test difference exists
os windows? cpu x86.64? and [
    { t } +fp-inexact+ [ 2.0 -100,000.0 ] [ fpow ] test-fp-exception unit-test
    { t } +fp-inexact+ [ 2.0 -100,000.0 ] [ fpow ] test-fp-exception-compiled unit-test
] [
    { t } +fp-underflow+ [ 2.0 -100,000.0 ] [ fpow ] test-fp-exception unit-test
    { t } +fp-underflow+ [ 2.0 -100,000.0 ] [ fpow ] test-fp-exception-compiled unit-test
] if

{ t } +fp-invalid-operation+ [ 0.0 0.0 ] [ /f ] test-fp-exception-compiled unit-test
{ t } +fp-invalid-operation+ [ -1.0 ] [ fsqrt ] test-fp-exception-compiled unit-test

{
    0x3fd5,5555,5555,5555
    0x3fc9,9999,9999,999a
    0xbfc9,9999,9999,999a
    0xbfd5,5555,5555,5555
} [
    +round-nearest+ [
         1.0 3.0 /f double>bits
         1.0 5.0 /f double>bits
        -1.0 5.0 /f double>bits
        -1.0 3.0 /f double>bits
    ] with-rounding-mode
] unit-test

{
    0x3fd5,5555,5555,5555
    0x3fc9,9999,9999,9999
    0xbfc9,9999,9999,999a
    0xbfd5,5555,5555,5556
} [
    +round-down+ [
         1.0 3.0 /f double>bits
         1.0 5.0 /f double>bits
        -1.0 5.0 /f double>bits
        -1.0 3.0 /f double>bits
    ] with-rounding-mode
] unit-test

{
    0x3fd5,5555,5555,5556
    0x3fc9,9999,9999,999a
    0xbfc9,9999,9999,9999
    0xbfd5,5555,5555,5555
} [
    +round-up+ [
         1.0 3.0 /f double>bits
         1.0 5.0 /f double>bits
        -1.0 5.0 /f double>bits
        -1.0 3.0 /f double>bits
    ] with-rounding-mode
] unit-test

{
    0x3fd5,5555,5555,5555
    0x3fc9,9999,9999,9999
    0xbfc9,9999,9999,9999
    0xbfd5,5555,5555,5555
} [
    +round-zero+ [
         1.0 3.0 /f double>bits
         1.0 5.0 /f double>bits
        -1.0 5.0 /f double>bits
        -1.0 3.0 /f double>bits
    ] with-rounding-mode
] unit-test

! ensure rounding mode is restored to +round-nearest+
{
    0x3fd5,5555,5555,5555
    0x3fc9,9999,9999,999a
    0xbfc9,9999,9999,999a
    0xbfd5,5555,5555,5555
} [
     1.0 3.0 /f double>bits
     1.0 5.0 /f double>bits
    -1.0 5.0 /f double>bits
    -1.0 3.0 /f double>bits
] unit-test

: fp-trap-error? ( error -- ? )
    2 head ${ KERNEL-ERROR ERROR-FP-TRAP } = ;

: test-traps ( traps inputs quot -- quot' fail-quot )
    append '[ _ _ with-fp-traps ] [ fp-trap-error? ] ;

: test-traps-compiled ( traps inputs quot -- quot' fail-quot )
    swapd '[ @ [ _ _ with-fp-traps ] compile-call ] [ fp-trap-error? ] ;

{ +fp-zero-divide+ } [ 1.0 0.0 ] [ /f ] test-traps must-fail-with
{ +fp-inexact+ } [ 1.0 3.0 ] [ /f ] test-traps must-fail-with
{ +fp-invalid-operation+ } [ -1.0 ] [ fsqrt ] test-traps must-fail-with
{ +fp-overflow+ } [ 2.0 ] [ 100,000.0 ^ ] test-traps must-fail-with
{ +fp-underflow+ +fp-inexact+ } [ 2.0 ] [ -100,000.0 ^ ] test-traps must-fail-with

{ +fp-zero-divide+ } [ 1.0 0.0 ] [ /f ] test-traps-compiled must-fail-with
{ +fp-inexact+ } [ 1.0 3.0 ] [ /f ] test-traps-compiled must-fail-with
{ +fp-invalid-operation+ } [ -1.0 ] [ fsqrt ] test-traps-compiled must-fail-with
{ +fp-overflow+ } [ 2.0 ] [ 100,000.0 ^ ] test-traps-compiled must-fail-with
{ +fp-underflow+ +fp-inexact+ } [ 2.0 ] [ -100,000.0 ^ ] test-traps-compiled must-fail-with

! Ensure ordered comparisons raise traps
:: test-comparison-quot ( word -- quot )
    [
        { float float } declare
        { +fp-invalid-operation+ } [ word execute ] with-fp-traps
    ] ;

: test-comparison ( inputs word -- quot fail-quot )
    test-comparison-quot append [ fp-trap-error? ] ;

: test-comparison-compiled ( inputs word -- quot fail-quot )
    test-comparison-quot '[ @ _ compile-call ] [ fp-trap-error? ] ;

\ float< "intrinsic" word-prop [
    [ 0/0. -15.0 ] \ < test-comparison must-fail-with
    [ 0/0. -15.0 ] \ < test-comparison-compiled must-fail-with
    [ -15.0 0/0. ] \ < test-comparison must-fail-with
    [ -15.0 0/0. ] \ < test-comparison-compiled must-fail-with
    [ 0/0. -15.0 ] \ <= test-comparison must-fail-with
    [ 0/0. -15.0 ] \ <= test-comparison-compiled must-fail-with
    [ -15.0 0/0. ] \ <= test-comparison must-fail-with
    [ -15.0 0/0. ] \ <= test-comparison-compiled must-fail-with
    [ 0/0. -15.0 ] \ > test-comparison must-fail-with
    [ 0/0. -15.0 ] \ > test-comparison-compiled must-fail-with
    [ -15.0 0/0. ] \ > test-comparison must-fail-with
    [ -15.0 0/0. ] \ > test-comparison-compiled must-fail-with
    [ 0/0. -15.0 ] \ >= test-comparison must-fail-with
    [ 0/0. -15.0 ] \ >= test-comparison-compiled must-fail-with
    [ -15.0 0/0. ] \ >= test-comparison must-fail-with
    [ -15.0 0/0. ] \ >= test-comparison-compiled must-fail-with

    [ f ] [ 0/0. -15.0 ] \ u< test-comparison drop unit-test
    [ f ] [ 0/0. -15.0 ] \ u< test-comparison-compiled drop unit-test
    [ f ] [ -15.0 0/0. ] \ u< test-comparison drop unit-test
    [ f ] [ -15.0 0/0. ] \ u< test-comparison-compiled drop unit-test
    [ f ] [ 0/0. -15.0 ] \ u<= test-comparison drop unit-test
    [ f ] [ 0/0. -15.0 ] \ u<= test-comparison-compiled drop unit-test
    [ f ] [ -15.0 0/0. ] \ u<= test-comparison drop unit-test
    [ f ] [ -15.0 0/0. ] \ u<= test-comparison-compiled drop unit-test
    [ f ] [ 0/0. -15.0 ] \ u> test-comparison drop unit-test
    [ f ] [ 0/0. -15.0 ] \ u> test-comparison-compiled drop unit-test
    [ f ] [ -15.0 0/0. ] \ u> test-comparison drop unit-test
    [ f ] [ -15.0 0/0. ] \ u> test-comparison-compiled drop unit-test
    [ f ] [ 0/0. -15.0 ] \ u>= test-comparison drop unit-test
    [ f ] [ 0/0. -15.0 ] \ u>= test-comparison-compiled drop unit-test
    [ f ] [ -15.0 0/0. ] \ u>= test-comparison drop unit-test
    [ f ] [ -15.0 0/0. ] \ u>= test-comparison-compiled drop unit-test
] when

! Ensure traps get cleared
{ 1/0. } [ 1.0 0.0 /f ] unit-test

! Ensure state is back to normal
{ +round-nearest+ } [ rounding-mode ] unit-test
{ +denormal-keep+ } [ denormal-mode ] unit-test
{ { } } [ fp-traps ] unit-test

{ } [
    all-fp-exceptions [ compact-gc ] with-fp-traps
] unit-test

! In case the tests screw up the FP env because of bugs in math.floats.env
set-default-fp-env
