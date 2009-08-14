USING: kernel compiler.cfg.two-operand compiler.cfg.instructions
compiler.cfg.registers cpu.architecture namespaces tools.test ;
IN: compiler.cfg.two-operand.tests

3 vreg-counter set-global

[
    V{
        T{ ##copy f 1 2 int-rep }
        T{ ##sub f 1 1 3 }
    }
] [
    H{
        { 1 int-rep }
        { 2 int-rep }
        { 3 int-rep }
    } clone representations set
    {
        T{ ##sub f 1 2 3 }
    } (convert-two-operand)
] unit-test

[
    V{
        T{ ##copy f 1 2 double-float-rep }
        T{ ##sub-float f 1 1 3 }
    }
] [
    H{
        { 1 double-float-rep }
        { 2 double-float-rep }
        { 3 double-float-rep }
    } clone representations set
    {
        T{ ##sub-float f 1 2 3 }
    } (convert-two-operand)
] unit-test

[
    V{
        T{ ##copy f 1 2 double-float-rep }
        T{ ##mul-float f 1 1 1 }
    }
] [
    H{
        { 1 double-float-rep }
        { 2 double-float-rep }
    } clone representations set
    {
        T{ ##mul-float f 1 2 2 }
    } (convert-two-operand)
] unit-test
