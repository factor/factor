USING: accessors compiler.cfg compiler.cfg.build-stack-frame
compiler.cfg.instructions compiler.cfg.stack-frame kernel slots.syntax
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
    } dup finalize-stack-frame
    slots[ allot-area-base spill-area-base total-size ]
] unit-test
