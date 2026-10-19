! Clang SysV PowerPC32 passes aggregates indirectly and returns small aggregates in GPRs.
USING: cpu.architecture cpu.ppc.32.abi cpu.ppc.32.svr4 kernel system ;
QUALIFIED: cpu.ppc.32.svr4
IN: cpu.ppc.32.clang

M: ppc.32 param-regs
    drop {
        { int-regs { 3 4 5 6 7 8 9 10 } }
        { float-regs { 1 2 3 4 5 6 7 8 } }
    } ;

M: ppc.32 value-struct? drop f ;
M: ppc.32 dummy-stack-params? f ;
M: ppc.32 dummy-int-params? f ;
M: ppc.32 dummy-fp-params? f ;
M: ppc.32 long-long-on-stack? f ;
M: ppc.32 long-long-odd-register? t ;
M: ppc.32 float-right-align-on-stack? f ;

! Preserve the existing helper API.
: ppc32-return-components ( size -- offsets parts )
    cpu.ppc.32.svr4:ppc32-return-components ;
