USING: compiler.cfg.parallel-copy tools.test arrays
compiler.cfg.registers namespaces compiler.cfg.instructions
cpu.architecture ;
IN: compiler.cfg.parallel-copy.tests

SYMBOL: temp

: test-parallel-copy ( mapping -- seq )
    3 vreg-counter set-global parallel-copy ;

{
    { }
} [
    H{ } test-parallel-copy
] unit-test

{
    {
        T{ ##copy f 4 2 any-rep }
        T{ ##copy f 2 1 any-rep }
        T{ ##copy f 1 4 any-rep }
    }
} [
    H{
        { 1 2 }
        { 2 1 }
    } test-parallel-copy
] unit-test

{
    {
        T{ ##copy f 1 2 any-rep }
        T{ ##copy f 3 4 any-rep }
    }
} [
    H{
        { 1 2 }
        { 3 4 }
    } test-parallel-copy
] unit-test

{
    {
        T{ ##copy f 1 3 any-rep }
        T{ ##copy f 2 1 any-rep }
    }
} [
    H{
        { 1 3 }
        { 2 3 }
    } test-parallel-copy
] unit-test

{
    {
        T{ ##copy f 4 3 any-rep }
        T{ ##copy f 3 2 any-rep }
        T{ ##copy f 2 1 any-rep }
        T{ ##copy f 1 4 any-rep }
    }
} [
    {
        { 2 1 }
        { 3 2 }
        { 1 3 }
        { 4 3 }
    } test-parallel-copy
] unit-test
