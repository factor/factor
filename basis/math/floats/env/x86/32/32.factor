USING: alien alien.c-types cpu.x86.assembler
cpu.x86.assembler.operands math.floats.env.x86 system ;
IN: math.floats.env.x86.32

M: x86.32 get-sse-env
    void { void* } cdecl [
        EAX ESP [] MOV
        EAX [] STMXCSR
    ] alien-assembly ;

M: x86.32 set-sse-env
    void { void* } cdecl [
        EAX ESP [] MOV
        EAX [] LDMXCSR
    ] alien-assembly ;

M: x86.32 get-x87-env
    void { void* } cdecl [
        EAX ESP [] MOV
        EAX [] FNSTSW
        EAX 2 [+] FNSTCW
    ] alien-assembly ;

M: x86.32 set-x87-env
    void { void* } cdecl [
        EAX ESP [] MOV
        FNCLEX
        EAX 2 [+] FLDCW
    ] alien-assembly ;
