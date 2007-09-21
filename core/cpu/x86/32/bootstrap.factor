! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: bootstrap.image.private kernel namespaces system
cpu.x86.assembler layouts vocabs ;
IN: bootstrap.x86.32

4 \ cell set
big-endian off

1 jit-code-format set

: ds-reg ESI ;
: scan-reg EBX ;
: xt-reg ECX ;
: scan-save ESP 12 [+] ;

[
    EAX EAX quot-array@ [+] MOV             ! load array
    scan-reg EAX 1 [+] LEA                  ! initialize scan pointer
] { } make jit-setup set

[
    xt-reg PUSH                             ! save XT
    xt-reg ESP -44 [+] LEA                  ! compute forward chain pointer
    xt-reg PUSH                             ! save forward chain pointer
    EAX PUSH                                ! save array
    ESP 16 SUB                              ! reserve space for scan-save
] { } make jit-prolog set

: advance-scan scan-reg 4 ADD ;

[
    advance-scan
    ds-reg 4 ADD                            ! increment datastack pointer
    EAX scan-reg [] MOV                     ! load literal
    ds-reg [] EAX MOV                       ! store literal on datastack
] { } make jit-push-literal set

[
    advance-scan
    ds-reg 4 ADD                            ! increment datastack pointer
    EAX scan-reg [] MOV                     ! load wrapper
    EAX dup wrapper@ [+] MOV                ! load wrapper-obj slot
    ds-reg [] EAX MOV                       ! store literal on datastack
] { } make jit-push-wrapper set

[
    EDX ESP MOV                             ! pass callstack pointer as arg 2
] { } make jit-word-primitive-jump set

[
    EDX ESP -4 [+] LEA                      ! pass callstack pointer as arg 2
] { } make jit-word-primitive-call set

[
    EAX scan-reg 4 [+] MOV                  ! load word
    EAX word-xt@ [+] JMP                    ! jump to word XT
] { } make jit-word-jump set

[
    advance-scan
    scan-save scan-reg MOV                  ! save scan pointer
    EAX scan-reg [] MOV                     ! load word
    EAX word-xt@ [+] CALL                   ! call word XT
    scan-reg scan-save MOV                  ! restore scan pointer
] { } make jit-word-call set

: load-branch
    EAX ds-reg [] MOV                       ! load boolean
    ds-reg 4 SUB                            ! pop boolean
    EAX \ f tag-number CMP                  ! compare it with f
    EAX scan-reg 8 [+] CMOVE                ! load false branch if equal
    EAX scan-reg 4 [+] CMOVNE               ! load true branch if not equal
    scan-reg 12 ADD                         ! advance scan pointer
    xt-reg EAX quot-xt@ [+] MOV             ! load quotation-xt
    ;

[
    load-branch
    xt-reg JMP
] { } make jit-if-jump set

[
    load-branch
    ESP [] scan-reg MOV                     ! save scan pointer
    xt-reg CALL                             ! call quotation
    scan-reg ESP [] MOV                     ! restore scan pointer
] { } make jit-if-call set

[
    EAX ds-reg [] MOV                       ! load index
    EAX 1 SAR                               ! turn it into an array offset
    ds-reg 4 SUB                            ! pop index
    EAX scan-reg 4 [+] ADD                  ! compute quotation location
    EAX EAX array-start [+] MOV             ! load quotation
    xt-reg EAX quot-xt@ [+] MOV             ! load quotation-xt
    xt-reg JMP                              ! execute quotation
] { } make jit-dispatch set

[
    ESP 28 ADD                              ! unwind stack frame
] { } make jit-epilog set

[ 0 RET ] { } make jit-return set

"bootstrap.x86.32" forget-vocab
