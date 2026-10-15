USING: compiler.cfg.builder.alien.params cpu.architecture
kernel math math.order namespaces sequences system vectors ;
IN: cpu.ppc.32.abi

! A scalar double that exhausts the FPR bank has eight-byte stack alignment.
! Its alignment is independent of the integer argument register bank.
M: ppc.32 alloc-abi-stack-param
    over double-rep = [
        stack-params get 8 align stack-params set
    ] when
    alloc-stack-param ;

! SysV PPC32 aligns two-word arguments to odd GPRs and eight-byte stack slots.
! Arguments without the pair-alignment marker retain their GPR position.
M: ppc.32 prepare-abi-parameter-group
    third [
        int-regs get dup empty? [ drop ] [
            dup last even? [ pop* ] [ drop ] if
        ] if
        int-regs get empty? [
            stack-params get 8 align stack-params set
        ] when
    ] when ;
