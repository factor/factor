USING: accessors compiler.cfg compiler.cfg.builder.blocks
compiler.cfg.comparisons compiler.cfg.instructions
compiler.cfg.intrinsics.fixnum compiler.cfg.registers
compiler.cfg.utilities compiler.test cpu.architecture kernel make
namespaces sequences ;
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

{
    V{
        T{ ##compare-integer-imm-branch
           { src1 1 }
           { src2 0 }
           { cc cc> }
        }
    }
    108
} [
    V{ } 108 insns>block dup set-basic-block
    emit-fixnum-shift-general
    predecessors>> first predecessors>> first
    [ instructions>> ] [ number>> ] bi
] cfg-unit-test

{
    V{
        T{ ##copy
           { dst 1 }
           { src 321 }
           { rep any-rep }
        }
        T{ ##inc { loc D: -1 } }
        T{ ##branch }
    }
    77
} [
    321 V{ } 77 insns>block emit-no-overflow-case
    first [ instructions>> ] [ predecessors>> first number>> ] bi
] cfg-unit-test

{
    V{ T{ ##call { word 2drop } } T{ ##branch } }
    107
} [
    \ 2drop V{ } 107 insns>block emit-overflow-case
    first [ instructions>> ] [ predecessors>> first number>> ] bi
] cfg-unit-test
