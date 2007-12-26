! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: bootstrap.image.private kernel namespaces system
cpu.x86.assembler layouts vocabs math generator.fixup ;
IN: bootstrap.x86

big-endian off

1 jit-code-format set

: stack-frame-size 8 bootstrap-cells ;

: scan-save stack-reg 3 bootstrap-cells [+] ;

[
    arg0 0 [] MOV                              ! load quotation
    arg1 arg0 quot-xt@ [+] MOV                 ! load XT
    arg0 arg0 quot-array@ [+] MOV              ! load array
    scan-reg arg0 scan@ [+] LEA                ! initialize scan pointer
] rc-absolute-cell rt-literal 2 jit-setup jit-define

[
    stack-frame-size PUSH                      ! save stack frame size
    arg1 PUSH                                  ! save XT
    arg0 PUSH                                  ! save array
    scan-reg PUSH                              ! initial scan
    stack-reg 3 bootstrap-cells SUB            ! reserved
] f f f jit-prolog jit-define

: advance-scan scan-reg bootstrap-cell ADD ;

[
    arg0 0 [] MOV                              ! load literal
    advance-scan
    ds-reg bootstrap-cell ADD                  ! increment datastack pointer
    ds-reg [] arg0 MOV                         ! store literal on datastack
] rc-absolute-cell rt-literal 2 jit-push-literal jit-define

[
    arg1 stack-reg MOV                         ! pass callstack pointer as arg 2
    (JMP) drop                                 ! go
] rc-relative rt-primitive 3 jit-word-primitive-jump jit-define

[
    advance-scan
    arg1 stack-reg bootstrap-cell neg [+] LEA  ! pass callstack pointer as arg 2
    scan-save scan-reg MOV                     ! save scan pointer
    (CALL) drop                                ! go
    scan-reg scan-save MOV                     ! restore scan pointer
] rc-relative rt-primitive 12 jit-word-primitive-call jit-define

[
    (JMP) drop
] rc-relative rt-xt 1 jit-word-jump jit-define

[
    advance-scan
    scan-save scan-reg MOV                     ! save scan pointer
    (CALL) drop
    scan-reg scan-save MOV                     ! restore scan pointer
] rc-relative rt-xt 8 jit-word-call jit-define

[
    arg1 0 MOV                                 ! load addr of true quotation
    arg0 ds-reg [] MOV                         ! load boolean
    ds-reg bootstrap-cell SUB                  ! pop boolean
    arg0 \ f tag-number CMP                    ! compare it with f
    arg0 arg1 [] CMOVNE                        ! load true branch if not equal
    arg0 arg1 bootstrap-cell [+] CMOVE         ! load false branch if equal
    arg0 quot-xt@ [+] JMP                      ! jump to quotation-xt
] rc-absolute-cell rt-literal 1 jit-if-jump jit-define

[
    arg1 0 [] MOV                              ! load dispatch table
    arg0 ds-reg [] MOV                         ! load index
    fixnum>slot@                               ! turn it into an array offset
    ds-reg bootstrap-cell SUB                  ! pop index
    arg0 arg1 ADD                              ! compute quotation location
    arg0 arg0 array-start [+] MOV              ! load quotation
    arg0 quot-xt@ [+] JMP                      ! execute branch
] rc-absolute-cell rt-literal 2 jit-dispatch jit-define

[
    stack-reg stack-frame-size bootstrap-cell - ADD ! unwind stack frame
] f f f jit-epilog jit-define

[ 0 RET ] f f f jit-return jit-define

"bootstrap.x86" forget-vocab
