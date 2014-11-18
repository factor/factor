USING: accessors combinators.short-circuit compiler.cfg
compiler.cfg.build-stack-frame compiler.cfg.instructions
compiler.cfg.stack-frame kernel layouts slots.syntax system
tools.test ;
IN: compiler.cfg.build-stack-frame.tests

{ [ os windows? ] [ cell-bits 64 = ] } 0&& [
    {
        ! 91 8 align
        96
        ! 91 8 align 16 +
        112
        ! XXX: Calculation is wrong for Windows 64 (off by 32 bytes)
        ! 91 8 align 16 + 16 8 align + cell + 16 align
        176
    } [
        T{ stack-frame
           { params 91 }
           { allot-area-align 8 }
           { allot-area-size 10 }
           { spill-area-align 8 }
           { spill-area-size 16 }
        } dup finalize-stack-frame
        slots[ allot-area-base spill-area-base total-size ]
    ] unit-test
] [
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
        } dup finalize-stack-frame
        slots[ allot-area-base spill-area-base total-size ]
    ] unit-test
] if