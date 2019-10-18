USING: alien alien.c-types cpu.architecture cpu.x86.assembler
cpu.x86.assembler.operands math.floats.env.x86 sequences system ;
IN: math.floats.env.x86.64

M: x86.64 get-sse-env
    void { void* } "cdecl" [
        int-regs param-regs first [] STMXCSR
    ] alien-assembly ;

M: x86.64 set-sse-env
    void { void* } "cdecl" [
        int-regs param-regs first [] LDMXCSR
    ] alien-assembly ;

M: x86.64 get-x87-env
    void { void* } "cdecl" [
        int-regs param-regs first [] FNSTSW
        int-regs param-regs first 2 [+] FNSTCW
    ] alien-assembly ;

M: x86.64 set-x87-env
    void { void* } "cdecl" [
        FNCLEX
        int-regs param-regs first 2 [+] FLDCW
    ] alien-assembly ;
