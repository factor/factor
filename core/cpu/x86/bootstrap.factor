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
    ! arg0 0 MOV                                 ! load quotation
    arg1 arg0 quot-xt@ [+] MOV                 ! load XT
    arg0 arg0 quot-array@ [+] MOV              ! load array
    scan-reg arg0 scan@ [+] LEA                ! initialize scan pointer
] rc-absolute-cell rt-literal 1 jit-setup jit-define

[
    stack-frame-size PUSH                      ! save stack frame size
    arg1 PUSH                                  ! save XT
    arg0 PUSH                                  ! save array
    scan-reg PUSH                              ! initial scan
    stack-reg 3 bootstrap-cells SUB            ! reserved
] f f f jit-prolog jit-define

: advance-scan scan-reg bootstrap-cell ADD ;

[
    advance-scan
    ds-reg bootstrap-cell ADD                  ! increment datastack pointer
    arg0 scan-reg [] MOV                       ! load literal
    ds-reg [] arg0 MOV                         ! store literal on datastack
] f f f jit-push-literal jit-define

[
    advance-scan
    ds-reg bootstrap-cell ADD                  ! increment datastack pointer
    arg0 scan-reg [] MOV                       ! load wrapper
    arg0 dup wrapper@ [+] MOV                  ! load wrapper-obj slot
    ds-reg [] arg0 MOV                         ! store literal on datastack
] f f f jit-push-wrapper jit-define

[
    arg1 stack-reg MOV                         ! pass callstack pointer as arg 2
] f f f jit-word-primitive-jump jit-define

[
    arg1 stack-reg bootstrap-cell neg [+] LEA  ! pass callstack pointer as arg 2
] f f f jit-word-primitive-call jit-define

[
    arg0 scan-reg bootstrap-cell [+] MOV       ! load word
    arg0 word-xt@ [+] JMP                      ! jump to word XT
] f f f jit-word-jump jit-define

[
    advance-scan
    scan-save scan-reg MOV                     ! save scan pointer
    arg0 scan-reg [] MOV                       ! load word
    arg0 word-xt@ [+] CALL                     ! call word XT
    scan-reg scan-save MOV                     ! restore scan pointer
] f f f jit-word-call jit-define

: load-branch
    arg0 ds-reg [] MOV                         ! load boolean
    ds-reg bootstrap-cell SUB                  ! pop boolean
    arg0 \ f tag-number CMP                    ! compare it with f
    arg0 scan-reg 2 bootstrap-cells [+] CMOVE  ! load false branch if equal
    arg0 scan-reg 1 bootstrap-cells [+] CMOVNE ! load true branch if not equal
    scan-reg 3 bootstrap-cells ADD             ! advance scan pointer
    arg0 quot-xt@ [+]                          ! load quotation-xt
    ;

[
    load-branch JMP
] f f f jit-if-jump jit-define

[
    load-branch
    scan-save scan-reg MOV                     ! save scan pointer
    CALL                                       ! call quotation
    scan-reg scan-save MOV                     ! restore scan pointer
] f f f jit-if-call jit-define

[
    arg0 ds-reg [] MOV                         ! load index
    fixnum>slot@                               ! turn it into an array offset
    ds-reg bootstrap-cell SUB                  ! pop index
    arg0 scan-reg bootstrap-cell [+] ADD       ! compute quotation location
    arg0 arg0 array-start [+] MOV              ! load quotation
    arg0 quot-xt@ [+] JMP                      ! jump to quotation-xt
] f f f jit-dispatch jit-define

[
    stack-reg stack-frame-size bootstrap-cell - ADD ! unwind stack frame
] f f f jit-epilog jit-define

[ 0 RET ] f f f jit-return jit-define

"bootstrap.x86" forget-vocab
