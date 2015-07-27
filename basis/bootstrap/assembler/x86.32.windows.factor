! Copyright (C) 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: compiler.codegen.relocation compiler.constants
cpu.x86.assembler cpu.x86.assembler.operands kernel layouts
locals parser sequences ;
IN: bootstrap.x86

: tib-segment ( -- ) FS ;
: tib-temp ( -- reg ) EAX ;

<< "vocab:bootstrap/assembler/x86.windows.factor" parse-file suffix! >> call

: jit-install-seh ( -- )
    ! Create a new exception record and store it in the TIB.
    ! Clobbers tib-temp.
    ! Align stack
    ESP 3 bootstrap-cells ADD
    ! Exception handler address filled in by callback.cpp
    tib-temp 0 MOV rc-absolute-cell rel-exception-handler
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
