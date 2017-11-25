USING: accessors compiler.cfg compiler.cfg.instructions
compiler.cfg.stack-frame compiler.cfg.utilities cpu.architecture
cpu.x86 kernel layouts math namespaces system tools.test ;
IN: cpu.architecture.tests

: cfg-w-spill-area-base ( base -- cfg )
    stack-frame new swap >>spill-area-base
    { } insns>cfg swap >>stack-frame ;

: expected-gc-root-offset ( slot-number spill-area-base -- offset )
    [ spill-slot boa ] [ cfg-w-spill-area-base ] bi*
    cfg [
        gc-root-offset reserved-stack-space cell / -
    ] with-variable ;

cpu x86.64? [
    ! The offset is 1, not 0 because the return address occupies the
    ! first position in the stack frame.
    { 1 } [ 0 0 expected-gc-root-offset ] unit-test

    { 10 } [ 8 64 expected-gc-root-offset ] unit-test

    { 20 } [ 24 128 expected-gc-root-offset ] unit-test
] when
