! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: bootstrap.image.private kernel kernel.private namespaces
system cpu.x86.assembler layouts compiler.units math
math.private compiler.constants vocabs slots.private words
words.private locals.backend ;
IN: bootstrap.x86

big-endian off

1 jit-code-format set

[
    ! Load word
    temp-reg 0 MOV
    ! Bump profiling counter
    temp-reg profile-count-offset [+] 1 tag-fixnum ADD
    ! Load word->code
    temp-reg temp-reg word-code-offset [+] MOV
    ! Compute word XT
    temp-reg compiled-header-size ADD
    ! Jump to XT
    temp-reg JMP
] rc-absolute-cell rt-immediate 1 rex-length + jit-profiling jit-define

[
    temp-reg 0 MOV                             ! load XT
    stack-frame-size PUSH                      ! save stack frame size
    temp-reg PUSH                              ! push XT
    stack-reg stack-frame-size 3 bootstrap-cells - SUB   ! alignment
] rc-absolute-cell rt-label 1 rex-length + jit-prolog jit-define

[
    arg0 0 MOV                                 ! load literal
    ds-reg bootstrap-cell ADD                  ! increment datastack pointer
    ds-reg [] arg0 MOV                         ! store literal on datastack
] rc-absolute-cell rt-immediate 1 rex-length + jit-push-immediate jit-define

[
    f JMP
] rc-relative rt-xt 1 jit-word-jump jit-define

[
    f CALL
] rc-relative rt-xt 1 jit-word-call jit-define

[
    arg0 ds-reg [] MOV                         ! load boolean
    ds-reg bootstrap-cell SUB                  ! pop boolean
    arg0 \ f tag-number CMP                    ! compare boolean with f
    f JNE                                      ! jump to true branch if not equal
] rc-relative rt-xt 10 rex-length 3 * + jit-if-1 jit-define

[
    f JMP                                      ! jump to false branch if equal
] rc-relative rt-xt 1 jit-if-2 jit-define

[
    arg1 0 MOV                                 ! load dispatch table
    arg0 ds-reg [] MOV                         ! load index
    fixnum>slot@                               ! turn it into an array offset
    ds-reg bootstrap-cell SUB                  ! pop index
    arg0 arg1 ADD                              ! compute quotation location
    arg0 arg0 array-start-offset [+] MOV       ! load quotation
    arg0 quot-xt-offset [+] JMP                ! execute branch
] rc-absolute-cell rt-immediate 1 rex-length + jit-dispatch jit-define

: jit->r ( -- )
    rs-reg bootstrap-cell ADD
    arg0 ds-reg [] MOV
    ds-reg bootstrap-cell SUB
    rs-reg [] arg0 MOV ;

: jit-2>r ( -- )
    rs-reg 2 bootstrap-cells ADD
    arg0 ds-reg [] MOV
    arg1 ds-reg -1 bootstrap-cells [+] MOV
    ds-reg 2 bootstrap-cells SUB
    rs-reg [] arg0 MOV
    rs-reg -1 bootstrap-cells [+] arg1 MOV ;

: jit-3>r ( -- )
    rs-reg 3 bootstrap-cells ADD
    arg0 ds-reg [] MOV
    arg1 ds-reg -1 bootstrap-cells [+] MOV
    arg2 ds-reg -2 bootstrap-cells [+] MOV
    ds-reg 3 bootstrap-cells SUB
    rs-reg [] arg0 MOV
    rs-reg -1 bootstrap-cells [+] arg1 MOV
    rs-reg -2 bootstrap-cells [+] arg2 MOV ;

: jit-r> ( -- )
    ds-reg bootstrap-cell ADD
    arg0 rs-reg [] MOV
    rs-reg bootstrap-cell SUB
    ds-reg [] arg0 MOV ;

: jit-2r> ( -- )
    ds-reg 2 bootstrap-cells ADD
    arg0 rs-reg [] MOV
    arg1 rs-reg -1 bootstrap-cells [+] MOV
    rs-reg 2 bootstrap-cells SUB
    ds-reg [] arg0 MOV
    ds-reg -1 bootstrap-cells [+] arg1 MOV ;

: jit-3r> ( -- )
    ds-reg 3 bootstrap-cells ADD
    arg0 rs-reg [] MOV
    arg1 rs-reg -1 bootstrap-cells [+] MOV
    arg2 rs-reg -2 bootstrap-cells [+] MOV
    rs-reg 3 bootstrap-cells SUB
    ds-reg [] arg0 MOV
    ds-reg -1 bootstrap-cells [+] arg1 MOV
    ds-reg -2 bootstrap-cells [+] arg2 MOV ;

[
    jit->r
    f CALL
    jit-r>
] rc-relative rt-xt 11 rex-length 4 * + jit-dip jit-define

[
    jit-2>r
    f CALL
    jit-2r>
] rc-relative rt-xt 17 rex-length 6 * + jit-2dip jit-define

[
    jit-3>r                                    
    f CALL
    jit-3r>
] rc-relative rt-xt 23 rex-length 8 * + jit-3dip jit-define

[
    stack-reg stack-frame-size bootstrap-cell - ADD ! unwind stack frame
] f f f jit-epilog jit-define

[ 0 RET ] f f f jit-return jit-define

! Sub-primitives

! Quotations and words
[
    arg0 ds-reg [] MOV                         ! load from stack
    ds-reg bootstrap-cell SUB                  ! pop stack
    arg0 quot-xt-offset [+] JMP                ! call quotation
] f f f \ (call) define-sub-primitive

[
    arg0 ds-reg [] MOV                         ! load from stack
    ds-reg bootstrap-cell SUB                  ! pop stack
    arg0 word-xt-offset [+] JMP                ! execute word
] f f f \ (execute) define-sub-primitive

! Objects
[
    arg1 ds-reg [] MOV                         ! load from stack
    arg1 tag-mask get AND                      ! compute tag
    arg1 tag-bits get SHL                      ! tag the tag
    ds-reg [] arg1 MOV                         ! push to stack
] f f f \ tag define-sub-primitive

[
    arg0 ds-reg [] MOV                         ! load slot number
    ds-reg bootstrap-cell SUB                  ! adjust stack pointer
    arg1 ds-reg [] MOV                         ! load object
    fixnum>slot@                               ! turn slot number into offset
    arg1 tag-bits get SHR                      ! mask off tag
    arg1 tag-bits get SHL
    arg0 arg1 arg0 [+] MOV                     ! load slot value
    ds-reg [] arg0 MOV                         ! push to stack
] f f f \ slot define-sub-primitive

! Shufflers
[
    ds-reg bootstrap-cell SUB
] f f f \ drop define-sub-primitive

[
    ds-reg 2 bootstrap-cells SUB
] f f f \ 2drop define-sub-primitive

[
    ds-reg 3 bootstrap-cells SUB
] f f f \ 3drop define-sub-primitive

[
    arg0 ds-reg [] MOV
    ds-reg bootstrap-cell ADD
    ds-reg [] arg0 MOV
] f f f \ dup define-sub-primitive

[
    arg0 ds-reg [] MOV
    arg1 ds-reg bootstrap-cell neg [+] MOV
    ds-reg 2 bootstrap-cells ADD
    ds-reg [] arg0 MOV
    ds-reg bootstrap-cell neg [+] arg1 MOV
] f f f \ 2dup define-sub-primitive

[
    arg0 ds-reg [] MOV
    arg1 ds-reg -1 bootstrap-cells [+] MOV
    temp-reg ds-reg -2 bootstrap-cells [+] MOV
    ds-reg 3 bootstrap-cells ADD
    ds-reg [] arg0 MOV
    ds-reg -1 bootstrap-cells [+] arg1 MOV
    ds-reg -2 bootstrap-cells [+] temp-reg MOV
] f f f \ 3dup define-sub-primitive

[
    arg0 ds-reg [] MOV
    ds-reg bootstrap-cell SUB
    ds-reg [] arg0 MOV
] f f f \ nip define-sub-primitive

[
    arg0 ds-reg [] MOV
    ds-reg 2 bootstrap-cells SUB
    ds-reg [] arg0 MOV
] f f f \ 2nip define-sub-primitive

[
    arg0 ds-reg -1 bootstrap-cells [+] MOV
    ds-reg bootstrap-cell ADD
    ds-reg [] arg0 MOV
] f f f \ over define-sub-primitive

[
    arg0 ds-reg -2 bootstrap-cells [+] MOV
    ds-reg bootstrap-cell ADD
    ds-reg [] arg0 MOV
] f f f \ pick define-sub-primitive

[
    arg0 ds-reg [] MOV
    arg1 ds-reg -1 bootstrap-cells [+] MOV
    ds-reg [] arg1 MOV
    ds-reg bootstrap-cell ADD
    ds-reg [] arg0 MOV
] f f f \ dupd define-sub-primitive

[
    arg0 ds-reg [] MOV
    arg1 ds-reg -1 bootstrap-cells [+] MOV
    ds-reg bootstrap-cell ADD
    ds-reg [] arg0 MOV
    ds-reg -1 bootstrap-cells [+] arg1 MOV
    ds-reg -2 bootstrap-cells [+] arg0 MOV
] f f f \ tuck define-sub-primitive

[
    arg0 ds-reg [] MOV
    arg1 ds-reg bootstrap-cell neg [+] MOV
    ds-reg bootstrap-cell neg [+] arg0 MOV
    ds-reg [] arg1 MOV
] f f f \ swap define-sub-primitive

[
    arg0 ds-reg -1 bootstrap-cells [+] MOV
    arg1 ds-reg -2 bootstrap-cells [+] MOV
    ds-reg -2 bootstrap-cells [+] arg0 MOV
    ds-reg -1 bootstrap-cells [+] arg1 MOV
] f f f \ swapd define-sub-primitive

[
    arg0 ds-reg [] MOV
    arg1 ds-reg -1 bootstrap-cells [+] MOV
    temp-reg ds-reg -2 bootstrap-cells [+] MOV
    ds-reg -2 bootstrap-cells [+] arg1 MOV
    ds-reg -1 bootstrap-cells [+] arg0 MOV
    ds-reg [] temp-reg MOV
] f f f \ rot define-sub-primitive

[
    arg0 ds-reg [] MOV
    arg1 ds-reg -1 bootstrap-cells [+] MOV
    temp-reg ds-reg -2 bootstrap-cells [+] MOV
    ds-reg -2 bootstrap-cells [+] arg0 MOV
    ds-reg -1 bootstrap-cells [+] temp-reg MOV
    ds-reg [] arg1 MOV
] f f f \ -rot define-sub-primitive

[ jit->r ] f f f \ >r define-sub-primitive

[ jit-r> ] f f f \ r> define-sub-primitive

! Comparisons
: jit-compare ( insn -- )
    temp-reg 0 MOV                             ! load t
    arg1 \ f tag-number MOV                    ! load f
    arg0 ds-reg [] MOV                         ! load first value
    ds-reg bootstrap-cell SUB                  ! adjust stack pointer
    ds-reg [] arg0 CMP                         ! compare with second value
    [ arg1 temp-reg ] dip execute              ! move t if true
    ds-reg [] arg1 MOV                         ! store
    ;

: define-jit-compare ( insn word -- )
    [ [ jit-compare ] curry rc-absolute-cell rt-immediate 1 rex-length + ] dip
    define-sub-primitive ;

\ CMOVE \ eq? define-jit-compare
\ CMOVGE \ fixnum>= define-jit-compare
\ CMOVLE \ fixnum<= define-jit-compare
\ CMOVG \ fixnum> define-jit-compare
\ CMOVL \ fixnum< define-jit-compare

! Math
: jit-math ( insn -- )
    arg0 ds-reg [] MOV                         ! load second input
    ds-reg bootstrap-cell SUB                  ! pop stack
    [ ds-reg [] arg0 ] dip execute             ! compute result
    ;

[ \ ADD jit-math ] f f f \ fixnum+fast define-sub-primitive

[ \ SUB jit-math ] f f f \ fixnum-fast define-sub-primitive

[
    arg0 ds-reg [] MOV                         ! load second input
    ds-reg bootstrap-cell SUB                  ! pop stack
    arg1 ds-reg [] MOV                         ! load first input
    arg0 tag-bits get SAR                      ! untag second input
    arg0 arg1 IMUL2                            ! multiply
    ds-reg [] arg1 MOV                         ! push result
] f f f \ fixnum*fast define-sub-primitive

[ \ AND jit-math ] f f f \ fixnum-bitand define-sub-primitive

[ \ OR jit-math ] f f f \ fixnum-bitor define-sub-primitive

[ \ XOR jit-math ] f f f \ fixnum-bitxor define-sub-primitive

[
    ds-reg [] NOT                              ! complement
    ds-reg [] tag-mask get XOR                 ! clear tag bits
] f f f \ fixnum-bitnot define-sub-primitive

[
    shift-arg ds-reg [] MOV                    ! load shift count
    shift-arg tag-bits get SAR                 ! untag shift count
    ds-reg bootstrap-cell SUB                  ! adjust stack pointer
    temp-reg ds-reg [] MOV                     ! load value
    arg1 temp-reg MOV                          ! make a copy
    arg1 CL SHL                                ! compute positive shift value in arg1
    shift-arg NEG                              ! compute negative shift value in arg0
    temp-reg CL SAR
    temp-reg tag-mask get bitnot AND
    shift-arg 0 CMP                            ! if shift count was negative, move arg0 to arg1
    arg1 temp-reg CMOVGE
    ds-reg [] arg1 MOV                         ! push to stack
] f f f \ fixnum-shift-fast define-sub-primitive

: jit-fixnum-/mod ( -- )
    temp-reg ds-reg [] MOV                     ! load second parameter
    div-arg ds-reg bootstrap-cell neg [+] MOV  ! load first parameter
    mod-arg div-arg MOV                        ! make a copy
    mod-arg bootstrap-cell-bits 1- SAR         ! sign-extend
    temp-reg IDIV ;                            ! divide

[
    jit-fixnum-/mod
    ds-reg bootstrap-cell SUB                  ! adjust stack pointer
    ds-reg [] mod-arg MOV                      ! push to stack
] f f f \ fixnum-mod define-sub-primitive

[
    jit-fixnum-/mod
    ds-reg bootstrap-cell SUB                  ! adjust stack pointer
    div-arg tag-bits get SHL                   ! tag it
    ds-reg [] div-arg MOV                      ! push to stack
] f f f \ fixnum/i-fast define-sub-primitive

[
    jit-fixnum-/mod
    div-arg tag-bits get SHL                   ! tag it
    ds-reg [] mod-arg MOV                      ! push to stack
    ds-reg bootstrap-cell neg [+] div-arg MOV
] f f f \ fixnum/mod-fast define-sub-primitive

[
    arg0 ds-reg [] MOV
    ds-reg bootstrap-cell SUB
    arg0 ds-reg [] OR
    arg0 tag-mask get AND
    arg0 \ f tag-number MOV
    arg1 1 tag-fixnum MOV
    arg0 arg1 CMOVE
    ds-reg [] arg0 MOV
] f f f \ both-fixnums? define-sub-primitive

[
    arg0 ds-reg [] MOV                         ! load local number
    fixnum>slot@                               ! turn local number into offset
    arg0 rs-reg arg0 [+] MOV                   ! load local value
    ds-reg [] arg0 MOV                         ! push to stack
] f f f \ get-local define-sub-primitive

[
    arg0 ds-reg [] MOV                         ! load local count
    ds-reg bootstrap-cell SUB                  ! adjust stack pointer
    fixnum>slot@                               ! turn local number into offset
    rs-reg arg0 SUB                            ! decrement retain stack pointer
] f f f \ drop-locals define-sub-primitive

[ "bootstrap.x86" forget-vocab ] with-compilation-unit
