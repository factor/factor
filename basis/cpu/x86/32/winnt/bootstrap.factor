! Copyright (C) 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: bootstrap.image.private compiler.constants
cpu.x86.assembler cpu.x86.assembler.operands kernel layouts
locals parser sequences ;
IN: bootstrap.x86

: tib-segment ( -- ) FS ;
: tib-temp ( -- reg ) EAX ;

<< "vocab:cpu/x86/winnt/bootstrap.factor" parse-file suffix! >> call

: jit-install-seh ( -- )
    ! Create a new exception record and store it in the TIB.
    ! Clobbers tib-temp.
    ! Align stack
    ESP 3 bootstrap-cells ADD
    ! Exception handler address filled in by callback.cpp
    tib-temp 0 MOV rc-absolute-cell rt-exception-handler jit-rel
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

<< "vocab:cpu/x86/32/bootstrap.factor" parse-file suffix! >> call
<< "vocab:cpu/x86/bootstrap.factor" parse-file suffix! >> call
