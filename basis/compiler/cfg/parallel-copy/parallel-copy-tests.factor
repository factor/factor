USING: compiler.cfg.parallel-copy tools.test make arrays
compiler.cfg.registers namespaces compiler.cfg.instructions
cpu.architecture ;
IN: compiler.cfg.parallel-copy.tests

SYMBOL: temp

: test-parallel-copy ( mapping -- seq )
    3 vreg-counter set-global
    [ parallel-copy ] { } make ;

[
    {
        T{ ##copy f V int-regs 4 V int-regs 2 }
        T{ ##copy f V int-regs 2 V int-regs 1 }
        T{ ##copy f V int-regs 1 V int-regs 4 }
    }
] [
    H{
        { V int-regs 1 V int-regs 2 }
        { V int-regs 2 V int-regs 1 }
    } test-parallel-copy
] unit-test

[
    {
        T{ ##copy f V int-regs 1 V int-regs 2 }
        T{ ##copy f V int-regs 3 V int-regs 4 }
    }
] [
    H{
        { V int-regs 1 V int-regs 2 }
        { V int-regs 3 V int-regs 4 }
    } test-parallel-copy
] unit-test

[
    {
        T{ ##copy f V int-regs 1 V int-regs 3 }
        T{ ##copy f V int-regs 2 V int-regs 1 }
    }
] [
    H{
        { V int-regs 1 V int-regs 3 }
        { V int-regs 2 V int-regs 3 }
    } test-parallel-copy
] unit-test

[
    {
        T{ ##copy f V int-regs 4 V int-regs 3 }
        T{ ##copy f V int-regs 3 V int-regs 2 }
        T{ ##copy f V int-regs 2 V int-regs 1 }
        T{ ##copy f V int-regs 1 V int-regs 4 }
    }
] [
    {
        { V int-regs 2 V int-regs 1 }
        { V int-regs 3 V int-regs 2 }
        { V int-regs 1 V int-regs 3 }
        { V int-regs 4 V int-regs 3 }
    } test-parallel-copy
] unit-test