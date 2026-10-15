USING: accessors classes.struct continuations kernel math.floats.env
math.floats.env.m68k math.floats.env.private sequences sets tools.test ;
IN: math.floats.env.m68k.tests

{ 0xa080 } [
    m68k-env (struct) 0xa080 >>fpcr
    +round-nearest+ (set-rounding-mode) fpcr>>
] unit-test
{ 0xa090 } [
    m68k-env (struct) 0xa080 >>fpcr
    +round-zero+ (set-rounding-mode) fpcr>>
] unit-test
{ 0xa0a0 } [
    m68k-env (struct) 0xa080 >>fpcr
    +round-down+ (set-rounding-mode) fpcr>>
] unit-test
{ 0xa0b0 } [
    m68k-env (struct) 0xa080 >>fpcr
    +round-up+ (set-rounding-mode) fpcr>>
] unit-test
{ t } [
    m68k-env (struct) 0xfff0 >>fpcr
    (get-fp-traps) all-fp-exceptions set=
] unit-test
{ 0xe380 } [
    m68k-env (struct) 0x80 >>fpcr
    { +fp-invalid-operation+ +fp-inexact+ } (set-fp-traps) fpcr>>
] unit-test
{ 0x80 } [
    m68k-env (struct) 0xff80 >>fpcr { } (set-fp-traps) fpcr>>
] unit-test
{ t } [
    m68k-env (struct) 0xf8 >>fpsr
    (get-exception-flags) all-fp-exceptions set=
] unit-test
{ 0xa55a0017 } [
    m68k-env (struct) 0xa55affff >>fpsr
    { +fp-zero-divide+ } (set-exception-flags) fpsr>>
] unit-test
{ 0xa55a0007 } [
    m68k-env (struct) 0xa55affff >>fpsr
    { } (set-exception-flags) fpsr>>
] unit-test
{ +denormal-keep+ } [ m68k-env (struct) (get-denormal-mode) ] unit-test
[ m68k-env (struct) +denormal-flush+ (set-denormal-mode) ]
[ unsupported-m68k-denormal-mode? ] must-fail-with
