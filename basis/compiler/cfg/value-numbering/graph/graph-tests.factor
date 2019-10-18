USING: arrays compiler.cfg.instructions
compiler.cfg.value-numbering.graph kernel namespaces tools.test ;
IN: compiler.cfg.value-numbering.graph.tests

{
    T{ ##and-imm { dst 4 } { src1 5 } { src2 6 } }
} [
    H{ { 10 10 } } vregs>vns set
    10 4 5 6 f ##and-imm boa 2array 1array vns>insns set
    10 vn>insn
] unit-test
