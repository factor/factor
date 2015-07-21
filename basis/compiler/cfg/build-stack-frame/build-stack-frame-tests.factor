USING: accessors compiler.cfg compiler.cfg.build-stack-frame
compiler.cfg.stack-frame cpu.x86 kernel math namespaces slots.syntax
tools.test ;
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
    t frame-required? set
    f f <basic-block> <cfg> dup build-stack-frame stack-frame>>
] unit-test
