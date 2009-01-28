USING: compiler.cfg.instructions compiler.cfg.registers
compiler.cfg.alias-analysis compiler.cfg.debugger
cpu.architecture tools.test kernel ;
IN: compiler.cfg.alias-analysis.tests

[ ] [
    {
        T{ ##peek f V int-regs 2 D 1 f }
        T{ ##box-alien f V int-regs 1 V int-regs 2 }
        T{ ##slot-imm f V int-regs 3 V int-regs 1 0 3 }
    } alias-analysis drop
] unit-test

[ ] [
    {
        T{ ##load-indirect f V int-regs 1 "hello" }
        T{ ##slot-imm f V int-regs 0 V int-regs 1 0 3 }
    } alias-analysis drop
] unit-test

[
    {
        T{ ##peek f V int-regs 1 D 1 f }
        T{ ##peek f V int-regs 2 D 2 f }
        T{ ##replace f V int-regs 1 D 0 f }
    }
] [
    {
        T{ ##peek f V int-regs 1 D 1 f }
        T{ ##peek f V int-regs 2 D 2 f }
        T{ ##replace f V int-regs 2 D 0 f }
        T{ ##replace f V int-regs 1 D 0 f }
    } alias-analysis
] unit-test

[
    {
        T{ ##peek f V int-regs 1 D 1 f }
        T{ ##peek f V int-regs 2 D 0 f }
        T{ ##copy f V int-regs 3 V int-regs 2 f }
        T{ ##copy f V int-regs 4 V int-regs 1 f }
        T{ ##replace f V int-regs 3 D 0 f }
        T{ ##replace f V int-regs 4 D 1 f }
    }
] [
    {
        T{ ##peek f V int-regs 1 D 1 f }
        T{ ##peek f V int-regs 2 D 0 f }
        T{ ##replace f V int-regs 1 D 0 f }
        T{ ##replace f V int-regs 2 D 1 f }
        T{ ##peek f V int-regs 3 D 1 f }
        T{ ##peek f V int-regs 4 D 0 f }
        T{ ##replace f V int-regs 3 D 0 f }
        T{ ##replace f V int-regs 4 D 1 f }
    } alias-analysis
] unit-test
