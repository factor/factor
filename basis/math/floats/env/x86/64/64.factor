USING: alien alien.c-types cpu.x86.64 cpu.x86.assembler
cpu.x86.assembler.operands math.floats.env.x86 system ;
IN: math.floats.env.x86.64

M: x86.64 get-sse-env
    void { void* } cdecl [
        param-reg-0 [] STMXCSR
    ] alien-assembly ;

M: x86.64 set-sse-env
    void { void* } cdecl [
        param-reg-0 [] LDMXCSR
    ] alien-assembly ;

M: x86.64 get-x87-env
    void { void* } cdecl [
        ! FWAIT ensures all pending FP operations complete
        ! before we read the status word
        FWAIT
        param-reg-0 [] FNSTSW
        param-reg-0 2 [+] FNSTCW
    ] alien-assembly ;

M: x86.64 set-x87-env
    void { void* } cdecl [
        FNCLEX
        param-reg-0 2 [+] FLDCW
    ] alien-assembly ;
