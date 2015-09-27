USING: compiler.cfg.comparisons compiler.cfg.instructions
compiler.cfg.intrinsics.fixnum compiler.test make tools.test ;
IN: compiler.cfg.intrinsics.fixnum.tests

{
    V{
        T{ ##compare-integer
           { dst 4 }
           { src1 1 }
           { src2 2 }
           { cc cc> }
           { temp 3 }
        }
    }
} [
    [ cc> emit-fixnum-comparison ] V{ } make
] cfg-unit-test
