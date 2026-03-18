USING: accessors compiler.cfg.build-stack-frame
compiler.cfg.instructions compiler.cfg.linearization
compiler.cfg.stack-frame compiler.cfg.utilities kernel math
sequences tools.test ;
IN: compiler.cfg.build-stack-frame.tests

{ f } [
    { } insns>cfg dup build-stack-frame stack-frame>>
] unit-test

{ t } [
    { T{ ##call-gc } } insns>cfg dup build-stack-frame
    stack-frame>> stack-frame?
] unit-test

{ 0 } [
    {
        T{ ##call-gc }
        T{ ##local-allot { dst 1 } { size 32 } { align 8 } }
    } insns>cfg dup build-stack-frame cfg>insns last offset>>
] unit-test
