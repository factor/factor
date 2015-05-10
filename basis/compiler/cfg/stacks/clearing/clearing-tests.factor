USING: compiler.cfg.instructions compiler.cfg.linearization
compiler.cfg.registers compiler.cfg.stacks.clearing compiler.cfg.utilities
kernel tools.test ;
IN: compiler.cfg.stacks.clearing.tests

! clear-uninitialized
{
    V{
        T{ ##inc { loc D 2 } { insn# 0 } }
        T{ ##replace-imm { src 17 } { loc T{ ds-loc { n 1 } } } }
        T{ ##replace-imm { src 17 } { loc T{ ds-loc } } }
        T{ ##peek { loc D 2 } { insn# 1 } }
    }
} [
    { T{ ##inc f D 2 } T{ ##peek f f D 2 } } insns>cfg
    dup clear-uninitialized cfg>insns
] unit-test

! dangerous-insn?
{ t f f } [
    { { 0 { } } { 0 { } } } T{ ##peek { loc D 0 } } dangerous-insn?
    { { 1 { 0 } } { 0 { } } } T{ ##peek { loc D 0 } } dangerous-insn?
    { { 0 { -1 } } { 0 { } } } T{ ##peek { loc D -1 } } dangerous-insn?
] unit-test

! state>replaces
{
    {
        T{ ##replace-imm { src 17 } { loc D 1 } }
        T{ ##replace-imm { src 17 } { loc D 0 } }
    }
} [
    { { 2 { } } { 0 { } } } state>replaces
] unit-test

{ { } } [
    { { 0 { } } { 0 { } } } state>replaces
] unit-test

{
    {
        T{ ##replace-imm { src 17 } { loc T{ ds-loc } } }
        T{ ##replace-imm { src 17 } { loc T{ rs-loc } } }
    }
} [
    { { 1 { } } { 1 { } } } state>replaces
] unit-test
