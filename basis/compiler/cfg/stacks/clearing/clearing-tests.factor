USING: compiler.cfg.instructions compiler.cfg.linearization
compiler.cfg.registers compiler.cfg.stacks.clearing compiler.cfg.utilities
kernel tools.test ;
IN: compiler.cfg.stacks.clearing.tests

{ { } } [
    { { 0 { } } { 0 { } } } state>replaces
] unit-test

{ t f f } [
    { { 0 { } } { 0 { } } } T{ ##peek { loc D 0 } } dangerous-insn?
    { { 1 { 0 } } { 0 { } } } T{ ##peek { loc D 0 } } dangerous-insn?
    { { 0 { -1 } } { 0 { } } } T{ ##peek { loc D -1 } } dangerous-insn?
] unit-test

{
    {
        T{ ##replace-imm { src 17 } { loc D 0 } }
        T{ ##replace-imm { src 17 } { loc D 1 } }
    }
} [
    { { 2 { } } { 0 { } } } state>replaces
] unit-test

{
    V{
        T{ ##inc-d { n 2 } { insn# 0 } }
        T{ ##replace-imm { src 17 } { loc T{ ds-loc } } }
        T{ ##replace-imm { src 17 } { loc T{ ds-loc { n 1 } } } }
        T{ ##peek { loc T{ ds-loc { n 2 } } } { insn# 1 } }
    }
} [
    { T{ ##inc-d f 2 } T{ ##peek f f D 2 } } insns>cfg
    dup clear-uninitialized cfg>insns
] unit-test
