USING: accessors compiler.cfg.instructions compiler.cfg.stack-frame
cpu.architecture cpu.x86 kernel layouts math namespaces system tools.test ;
IN: cpu.architecture.tests

: expected-gc-root-offset ( slot-number spill-area-base -- offset )
    [ spill-slot boa ] [ stack-frame new swap >>spill-area-base ] bi*
    stack-frame [
        gc-root-offset reserved-stack-space cell / -
    ] with-variable ;

cpu x86.64? [
    ! The offset is 1, not 0 because the return address occupies the
    ! first position in the stack frame.
    { 1 } [ 0 0 expected-gc-root-offset ] unit-test

    { 10 } [ 8 64 expected-gc-root-offset ] unit-test

    { 20 } [ 24 128 expected-gc-root-offset ] unit-test
] when
