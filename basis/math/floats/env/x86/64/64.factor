USING: alien alien.c-types cpu.x86.64 cpu.x86.assembler
cpu.x86.assembler.operands math.floats.env.x86 system ;
IN: math.floats.env.x86.64

! FXSAVE implementation - atomic read of both x87 and SSE state
! Memory layout:
! Offset 0:  FCW (x87 control word) - 2 bytes
! Offset 2:  FSW (x87 status word) - 2 bytes
! Offset 24: MXCSR (SSE status/control) - 4 bytes

M: x86.64 get-sse-env
    void { void* } cdecl [
        RSP 512 SUB
        RSP [] FXSAVE
        EAX RSP 24 [+] MOV
        param-reg-0 [] EAX MOV
        RSP 512 ADD
    ] alien-assembly ;

M: x86.64 set-sse-env
    void { void* } cdecl [
        RSP 512 SUB
        RSP [] FXSAVE
        EAX param-reg-0 [] MOV
        RSP 24 [+] EAX MOV
        RSP [] FXRSTOR
        RSP 512 ADD
    ] alien-assembly ;

M: x86.64 get-x87-env
    void { void* } cdecl [
        RSP 512 SUB
        RSP [] FXSAVE
        AX RSP 2 [+] MOV
        param-reg-0 [] AX MOV
        AX RSP [] MOV
        param-reg-0 2 [+] AX MOV
        RSP 512 ADD
    ] alien-assembly ;

M: x86.64 set-x87-env
    void { void* } cdecl [
        RSP 512 SUB
        RSP [] FXSAVE
        AX param-reg-0 2 [+] MOV
        RSP [] AX MOV
        RSP [] FXRSTOR
        RSP 512 ADD
    ] alien-assembly ;

! XSAVE/XRSTOR version (if we detect AVX support)
! Requires XSAVE feature (CPUID.01H:ECX.XSAVE[bit 26])
! Uses XCR0 to select components:
!   bit 0 = x87 state
!   bit 1 = SSE state
!   bit 2 = AVX state (YMM registers)

! M: x86.64 get-sse-env-xsave
!     void { void* } cdecl [
!         ! Set feature mask in EDX:EAX for x87+SSE (bits 0,1)
!         EAX 3 MOV
!         XOR EDX EDX
!         RSP 512 SUB
!         RSP [] XSAVE
!         EAX RSP 24 [+] MOV
!         param-reg-0 [] EAX MOV
!         RSP 512 ADD
!     ] alien-assembly ;

! M: x86.64 set-sse-env-xsave
!     void { void* } cdecl [
!         EAX 3 MOV
!         XOR EDX EDX
!         RSP 512 SUB
!         RSP [] XSAVE
!         EAX param-reg-0 [] MOV
!         RSP 24 [+] EAX MOV
!         RSP [] XRSTOR
!         RSP 512 ADD
!     ] alien-assembly ;