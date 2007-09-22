! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: bootstrap.image.private kernel namespaces system
cpu.x86.assembler layouts vocabs math ;
IN: bootstrap.x86

big-endian off

1 jit-code-format set

: scan-save stack-reg 3 bootstrap-cells [+] ;

[
    arg0 arg0 quot-array@ [+] MOV              ! load array
    scan-reg arg0 scan@ [+] LEA                ! initialize scan pointer
] { } make jit-setup set                       
                                               
[                                              
    xt-reg PUSH                                ! save XT
    xt-reg stack-reg -44 [+] LEA               ! compute forward chain pointer
    xt-reg PUSH                                ! save forward chain pointer
    arg0 PUSH                                  ! save array
    stack-reg 2 bootstrap-cells SUB            ! reserve space for scan-save
] { } make jit-prolog set                      
                                               
: advance-scan scan-reg bootstrap-cell ADD ;   
                                               
[                                              
    advance-scan                               
    ds-reg bootstrap-cell ADD                  ! increment datastack pointer
    arg0 scan-reg [] MOV                       ! load literal
    ds-reg [] arg0 MOV                         ! store literal on datastack
] { } make jit-push-literal set                
                                               
[                                              
    advance-scan                               
    ds-reg bootstrap-cell ADD                  ! increment datastack pointer
    arg0 scan-reg [] MOV                       ! load wrapper
    arg0 dup wrapper@ [+] MOV                  ! load wrapper-obj slot
    ds-reg [] arg0 MOV                         ! store literal on datastack
] { } make jit-push-wrapper set                
                                               
[                                              
    arg1 stack-reg MOV                         ! pass callstack pointer as arg 2
] { } make jit-word-primitive-jump set         
                                               
[                                              
    arg1 stack-reg bootstrap-cell neg [+] LEA  ! pass callstack pointer as arg 2
] { } make jit-word-primitive-call set         
                                               
[                                              
    arg0 scan-reg bootstrap-cell [+] MOV       ! load word
    arg0 word-xt@ [+] JMP                      ! jump to word XT
] { } make jit-word-jump set                   
                                               
[                                              
    advance-scan                               
    scan-save scan-reg MOV                     ! save scan pointer
    arg0 scan-reg [] MOV                       ! load word
    arg0 word-xt@ [+] CALL                     ! call word XT
    scan-reg scan-save MOV                     ! restore scan pointer
] { } make jit-word-call set                   
                                               
: load-branch                                  
    arg0 ds-reg [] MOV                         ! load boolean
    ds-reg bootstrap-cell SUB                  ! pop boolean
    arg0 \ f tag-number CMP                    ! compare it with f
    arg0 scan-reg 2 bootstrap-cells [+] CMOVE  ! load false branch if equal
    arg0 scan-reg 1 bootstrap-cells [+] CMOVNE ! load true branch if not equal
    scan-reg 3 bootstrap-cells ADD             ! advance scan pointer
    xt-reg arg0 quot-xt@ [+] MOV               ! load quotation-xt
    ;

[
    load-branch
    xt-reg JMP
] { } make jit-if-jump set

[
    load-branch
    stack-reg [] scan-reg MOV                  ! save scan pointer
    xt-reg CALL                                ! call quotation
    scan-reg stack-reg [] MOV                  ! restore scan pointer
] { } make jit-if-call set

[
    arg0 ds-reg [] MOV                         ! load index
    fixnum>slot@                               ! turn it into an array offset
    ds-reg bootstrap-cell SUB                  ! pop index
    arg0 scan-reg bootstrap-cell [+] ADD       ! compute quotation location
    arg0 arg0 array-start [+] MOV              ! load quotation
    xt-reg arg0 quot-xt@ [+] MOV               ! load quotation-xt
    xt-reg JMP                                 ! execute quotation
] { } make jit-dispatch set

[
    stack-reg 7 cells ADD                      ! unwind stack frame
] { } make jit-epilog set

[ 0 RET ] { } make jit-return set

"bootstrap.x86" forget-vocab
