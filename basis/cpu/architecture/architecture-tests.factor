USING: compiler.cfg.instructions compiler.cfg.stack-frame kernel namespaces
system tools.test ;
IN: cpu.architecture

cpu x86.64? [
    ! The offset is 1, not 0 because the return address occupies the
    ! first position in the stack frame.
    { 1 } [
        T{ stack-frame { spill-area-base 0 } } stack-frame [
            T{ spill-slot { n 0 } } gc-root-offset
        ] with-variable
    ] unit-test

    { 10 } [
        T{ stack-frame { spill-area-base 64 } } stack-frame [
            T{ spill-slot { n 8 } } gc-root-offset
        ] with-variable
    ] unit-test
] when
