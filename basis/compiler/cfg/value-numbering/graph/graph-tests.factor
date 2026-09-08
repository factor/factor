USING: accessors arrays compiler.cfg compiler.cfg.instructions
compiler.cfg.registers compiler.cfg.utilities compiler.cfg.value-numbering
compiler.cfg.value-numbering.graph cpu.architecture kernel locals namespaces
sequences tools.test ;
IN: compiler.cfg.value-numbering.graph.tests

{
    T{ ##and-imm { dst 4 } { src1 5 } { src2 6 } }
} [
    H{ { 10 10 } } vregs>vns set
    10 4 5 6 f ##and-imm boa 2array 1array vns>insns set
    10 vn>insn
] unit-test

! SSA constants, including copies of them, remain available in later blocks.
! This benefits the existing integer folders as well as float conversions.
{
    {
        T{ ##load-integer { dst 2 } { val -7 } }
        T{ ##load-integer { dst 3 } { val 12 } }
        T{ ##load-reference { dst 4 } { obj 7.0 } }
    }
} [
    [let
        V{
            T{ ##load-integer { dst 0 } { val 7 } }
            T{ ##branch }
        } 0 insns>block :> first-block
        V{
            T{ ##copy { dst 1 } { src 0 } { rep any-rep } }
            T{ ##branch }
        } 1 insns>block :> second-block
        V{
            T{ ##neg { dst 2 } { src 1 } }
            T{ ##add-imm { dst 3 } { src1 1 } { src2 5 } }
            T{ ##integer>float { dst 4 } { src 1 } }
            T{ ##return }
        } 2 insns>block :> third-block
        first-block second-block connect-bbs
        second-block third-block connect-bbs
        first-block block>cfg value-numbering
        third-block instructions>> 3 head >array
    ]
] unit-test

! A new CFG can reuse the same register numbers for nonconstant inputs.
{ t } [
    V{
        T{ ##peek { dst 0 } { loc D: 0 } }
        T{ ##neg { dst 1 } { src 0 } }
        T{ ##return }
    } insns>cfg dup value-numbering
    entry>> instructions>> second ##neg?
] unit-test
