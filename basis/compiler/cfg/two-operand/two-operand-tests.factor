IN: compiler.cfg.two-operand.tests
USING: compiler.cfg.two-operand compiler.cfg.instructions
compiler.cfg.registers cpu.architecture namespaces tools.test ;

3 vreg-counter set-global

[
    V{
        T{ ##copy f V int-regs 1 V int-regs 2 }
        T{ ##sub f V int-regs 1 V int-regs 1 V int-regs 3 }
    }
] [
    {
        T{ ##sub f V int-regs 1 V int-regs 2 V int-regs 3 }
    } (convert-two-operand)
] unit-test

[
    V{
        T{ ##sub f V int-regs 1 V int-regs 1 V int-regs 2 }
    }
] [
    {
        T{ ##sub f V int-regs 1 V int-regs 1 V int-regs 2 }
    } (convert-two-operand)
] unit-test

[
    V{
        T{ ##copy f V int-regs 4 V int-regs 1 }
        T{ ##copy f V int-regs 1 V int-regs 2 }
        T{ ##sub f V int-regs 1 V int-regs 1 V int-regs 4 }
    }
] [
    {
        T{ ##sub f V int-regs 1 V int-regs 2 V int-regs 1 }
    } (convert-two-operand)
] unit-test
