! Copyright (C) 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: bootstrap.image.private compiler.constants
cpu.x86.assembler cpu.x86.assembler.operands kernel layouts
locals parser sequences ;
IN: bootstrap.x86

: tib-exception-list-offset ( -- n ) 0 bootstrap-cells ;
: tib-stack-base-offset ( -- n ) 1 bootstrap-cells ;
: tib-stack-limit-offset ( -- n ) 2 bootstrap-cells ;

: jit-save-tib ( -- )
    tib-exception-list-offset [] FS PUSH
    tib-stack-base-offset [] FS PUSH
    tib-stack-limit-offset [] FS PUSH ;

: jit-restore-tib ( -- )
    tib-stack-limit-offset [] FS POP
    tib-stack-base-offset [] FS POP
    tib-exception-list-offset [] FS POP ;

:: jit-update-tib ( ctx-reg -- )
    ! There's a redundant load here because we're not allowed
    ! to clobber ctx-reg. Clobbers EAX.
    ! Save callstack base in TIB
    EAX ctx-reg context-callstack-seg-offset [+] MOV
    EAX EAX segment-end-offset [+] MOV
    tib-stack-base-offset [] EAX FS MOV
    ! Save callstack limit in TIB
    EAX ctx-reg context-callstack-seg-offset [+] MOV
    EAX EAX segment-start-offset [+] MOV
    tib-stack-limit-offset [] EAX FS MOV ;

: jit-install-seh ( -- )
    ! Create a new exception record and store it in the TIB.
    ! Align stack
    ESP 3 bootstrap-cells ADD
    ! Exception handler address filled in by callback.cpp
    0 PUSH rc-absolute-cell rt-exception-handler jit-rel
    ! No next handler
    0 PUSH
    ! This is the new exception handler
    tib-exception-list-offset [] ESP FS MOV ;

:: jit-update-seh ( ctx-reg -- )
    ! Load exception record structure that jit-install-seh
    ! created from the bottom of the callstack. Clobbers EAX.
    EAX ctx-reg context-callstack-bottom-offset [+] MOV
    EAX bootstrap-cell ADD
    ! Store exception record in TIB.
    tib-exception-list-offset [] EAX FS MOV ;

<< "vocab:cpu/x86/32/bootstrap.factor" parse-file suffix! >>
call
