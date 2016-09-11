USING: compiler.cfg.instructions compiler.cfg.linearization
compiler.cfg.registers compiler.cfg.stacks.clearing compiler.cfg.utilities
kernel tools.test ;
IN: compiler.cfg.stacks.clearing.tests

! clear-uninitialized
{
    V{
        T{ ##inc { loc D: 2 } { insn# 0 } }
        T{ ##clear { loc T{ ds-loc { n 1 } } } }
        T{ ##clear { loc T{ ds-loc } } }
        T{ ##peek { loc D: 2 } { insn# 1 } }
    }
} [
    { T{ ##inc f D: 2 } T{ ##peek f f D: 2 } } insns>cfg
    dup clear-uninitialized cfg>insns
] unit-test

! dangerous-insn?
{
    t f t t
} [
    { { 0 { } } { 0 { } } } T{ ##peek { loc D: 0 } } dangerous-insn?
    { { 1 { } } { 0 { } } } T{ ##peek { loc D: 0 } } dangerous-insn?
    { { 2 { 0 1 } } { 0 { } } } T{ ##peek { loc D: 2 } } dangerous-insn?
    { { 0 { } } { 3 { } } } T{ ##call-gc } dangerous-insn?
] unit-test

! state>clears
{
    { }
} [
    { { 2 { } } { 0 { } } } state>clears
] unit-test

{
    {
        T{ ##clear { loc T{ ds-loc { n 1 } } } }
        T{ ##clear { loc T{ ds-loc } } }
    }
} [
    { { 2 { 0 1 } } { 0 { } } } state>clears
] unit-test

{ { } } [
    { { 0 { } } { 0 { } } } state>clears
] unit-test

{
    {
        T{ ##clear { loc T{ ds-loc } } }
        T{ ##clear { loc T{ rs-loc } } }
    }
} [
    { { 1 { 0 } } { 1 { 0 } } } state>clears
] unit-test
