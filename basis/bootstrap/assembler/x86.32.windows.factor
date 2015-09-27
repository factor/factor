! Copyright (C) 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: compiler.codegen.relocation compiler.constants cpu.x86.assembler
cpu.x86.assembler.operands kernel kernel.private layouts locals parser
sequences ;
IN: bootstrap.x86

: tib-segment ( -- ) FS ;
: tib-temp ( -- reg ) EAX ;

<< "vocab:bootstrap/assembler/x86.windows.factor" parse-file suffix! >> call

: jit-install-seh ( -- )
    ! VM pointer must be in vm-reg already
    ! Create a new exception record and store it in the TIB.
    ! Clobbers tib-temp.
    ! Align stack
    ESP 3 bootstrap-cells ADD
    tib-temp EBX WIN-EXCEPTION-HANDLER vm-special-object-offset [+] MOV
    tib-temp tib-temp alien-offset [+] MOV
    tib-temp PUSH

    ! No next handler
    0 PUSH
    ! This is the new exception handler
    tib-exception-list-offset [] ESP tib-segment MOV ;

:: jit-update-seh ( ctx-reg -- )
    ! Load exception record structure that jit-install-seh
    ! created from the bottom of the callstack.
    ! Clobbers tib-temp.
    tib-temp ctx-reg context-callstack-bottom-offset [+] MOV
    tib-temp bootstrap-cell ADD
    ! Store exception record in TIB.
    tib-exception-list-offset [] tib-temp tib-segment MOV ;

<< "vocab:bootstrap/assembler/x86.32.factor" parse-file suffix! >> call
<< "vocab:bootstrap/assembler/x86.factor" parse-file suffix! >> call
