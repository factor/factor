USING: accessors compiler.cfg compiler.cfg.build-stack-frame
compiler.cfg.stack-frame kernel namespaces tools.test ;
IN: compiler.cfg.stack-frame.tests

{
    112
    ! 112 37 +
    149
} [
    T{ stack-frame
       { params 91 }
       { allot-area-align 8 }
       { allot-area-size 10 }
       { spill-area-align 8 }
       { spill-area-size 16 }
    } dup finalize-stack-frame
    [ spill-area-base>> ]
    [ stack-frame set 37 spill-offset ] bi
] unit-test
