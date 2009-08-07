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
        T{ ##copy f V int-rep 4 V int-rep 2 int-rep }
        T{ ##copy f V int-rep 2 V int-rep 1 int-rep }
        T{ ##copy f V int-rep 1 V int-rep 4 int-rep }
    }
] [
    H{
        { V int-rep 1 V int-rep 2 }
        { V int-rep 2 V int-rep 1 }
    } test-parallel-copy
] unit-test

[
    {
        T{ ##copy f V int-rep 1 V int-rep 2 int-rep }
        T{ ##copy f V int-rep 3 V int-rep 4 int-rep }
    }
] [
    H{
        { V int-rep 1 V int-rep 2 }
        { V int-rep 3 V int-rep 4 }
    } test-parallel-copy
] unit-test

[
    {
        T{ ##copy f V int-rep 1 V int-rep 3 int-rep }
        T{ ##copy f V int-rep 2 V int-rep 1 int-rep }
    }
] [
    H{
        { V int-rep 1 V int-rep 3 }
        { V int-rep 2 V int-rep 3 }
    } test-parallel-copy
] unit-test

[
    {
        T{ ##copy f V int-rep 4 V int-rep 3 int-rep }
        T{ ##copy f V int-rep 3 V int-rep 2 int-rep }
        T{ ##copy f V int-rep 2 V int-rep 1 int-rep }
        T{ ##copy f V int-rep 1 V int-rep 4 int-rep }
    }
] [
    {
        { V int-rep 2 V int-rep 1 }
        { V int-rep 3 V int-rep 2 }
        { V int-rep 1 V int-rep 3 }
        { V int-rep 4 V int-rep 3 }
    } test-parallel-copy
] unit-test