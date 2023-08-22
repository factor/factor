USING: accessors compiler.cfg.build-stack-frame
compiler.cfg.instructions compiler.cfg.linearization
compiler.cfg.stack-frame compiler.cfg.utilities cpu.x86 kernel math
sequences slots.syntax tools.test ;
IN: compiler.cfg.build-stack-frame.tests

{
    ! 91 8 align
    96
    ! 91 8 align 16 +
    112
    ! 91 8 align 16 + 16 8 align + cell + 16 align
    144
} [
    T{ stack-frame
        { params 91 }
        { allot-area-align 8 }
        { allot-area-size 10 }
        { spill-area-align 8 }
        { spill-area-size 16 }
    } finalize-stack-frame
    slots[ allot-area-base spill-area-base total-size ]
    ! Exclude any reserved stack space 32 bytes on win64, 0 bytes
    ! on all other platforms.
    reserved-stack-space -
] unit-test

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
