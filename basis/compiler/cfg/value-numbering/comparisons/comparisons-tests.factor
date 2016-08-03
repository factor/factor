USING: compiler.cfg.comparisons compiler.cfg.instructions
compiler.cfg.value-numbering.comparisons cpu.x86.assembler.operands
kernel tools.test ;
IN: compiler.cfg.value-numbering.comparisons.tests

{
    T{ ##test-branch { src1 RAX } { src2 RAX } { cc cc= } }
} [
    RAX 0 cc= f ##compare-integer-imm-branch boa >test-branch
] unit-test
