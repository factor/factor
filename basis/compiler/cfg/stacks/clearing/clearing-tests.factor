USING: compiler.cfg.instructions compiler.cfg.registers
compiler.cfg.stacks.clearing tools.test ;
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
