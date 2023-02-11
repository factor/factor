! Copyright (C) 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: compiler.constants cpu.x86.assembler
cpu.x86.assembler.operands layouts ;
IN: bootstrap.assembler.x86

: tib-exception-list-offset ( -- n ) 0 bootstrap-cells ;
: tib-stack-base-offset ( -- n ) 1 bootstrap-cells ;
: tib-stack-limit-offset ( -- n ) 2 bootstrap-cells ;

: jit-save-tib ( -- )
    tib-exception-list-offset [] tib-segment PUSH
    tib-stack-base-offset [] tib-segment PUSH
    tib-stack-limit-offset [] tib-segment PUSH ;

: jit-restore-tib ( -- )
    tib-stack-limit-offset [] tib-segment POP
    tib-stack-base-offset [] tib-segment POP
    tib-exception-list-offset [] tib-segment POP ;

:: jit-update-tib ( ctx-reg -- )
    ! There's a redundant load here because we're not allowed
    ! to clobber ctx-reg. Clobbers tib-temp.
    ! Save callstack base in TIB
    tib-temp ctx-reg context-callstack-seg-offset [+] MOV
    tib-temp tib-temp segment-end-offset [+] MOV
    tib-stack-base-offset [] tib-temp tib-segment MOV
    ! Save callstack limit in TIB
    tib-temp ctx-reg context-callstack-seg-offset [+] MOV
    tib-temp tib-temp segment-start-offset [+] MOV
    tib-stack-limit-offset [] tib-temp tib-segment MOV ;
