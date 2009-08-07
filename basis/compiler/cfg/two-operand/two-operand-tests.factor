IN: compiler.cfg.two-operand.tests
USING: compiler.cfg.two-operand compiler.cfg.instructions
compiler.cfg.registers cpu.architecture namespaces tools.test ;

3 vreg-counter set-global

[
    V{
        T{ ##copy f V int-rep 1 V int-rep 2 int-rep }
        T{ ##sub f V int-rep 1 V int-rep 1 V int-rep 3 }
    }
] [
    {
        T{ ##sub f V int-rep 1 V int-rep 2 V int-rep 3 }
    } (convert-two-operand)
] unit-test

[
    V{
        T{ ##copy f V double-float-rep 1 V double-float-rep 2 double-float-rep }
        T{ ##sub-float f V double-float-rep 1 V double-float-rep 1 V double-float-rep 3 }
    }
] [
    {
        T{ ##sub-float f V double-float-rep 1 V double-float-rep 2 V double-float-rep 3 }
    } (convert-two-operand)
] unit-test
