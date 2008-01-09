! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: bootstrap.image.private kernel namespaces system
cpu.ppc.assembler generator.fixup compiler.constants math
layouts words vocabs ;
IN: bootstrap.ppc

4 \ cell set
big-endian on

4 jit-code-format set

: ds-reg 14 ;
: quot-reg 3 ;
: temp-reg 6 ;
: aux-reg 11 ;

: factor-area-size 4 bootstrap-cells ;

: stack-frame
    factor-area-size c-area-size + 4 bootstrap-cells align ;

: next-save stack-frame bootstrap-cell - ;
: xt-save stack-frame 2 bootstrap-cells - ;

[
    ! Load word
    0 temp-reg LOAD32
    temp-reg dup 0 LWZ
    ! Bump profiling counter
    aux-reg temp-reg profile-count-offset LWZ
    aux-reg dup 1 tag-fixnum ADDI
    aux-reg temp-reg profile-count-offset STW
    ! Load word->code
    aux-reg temp-reg word-code-offset LWZ
    ! Compute word XT
    aux-reg dup compiled-header-size ADDI
    ! Jump to XT
    aux-reg MTCTR
    BCTR
] rc-absolute-ppc-2/2 rt-literal 1 jit-profiling jit-define

[
    0 temp-reg LOAD32                          ! load XT
    0 MFLR                                     ! load return address
    1 1 stack-frame neg ADDI                   ! create stack frame
    temp-reg 1 xt-save STW                     ! save XT
    stack-frame temp-reg LI                    ! load frame size
    temp-reg 1 next-save STW                   ! save frame size
    0 1 lr-save stack-frame + STW              ! save return address
] rc-absolute-ppc-2/2 rt-label 1 jit-prolog jit-define

[
    0 temp-reg LOAD32                          ! load literal
    temp-reg dup 0 LWZ                         ! indirection
    temp-reg ds-reg 4 STWU                     ! push literal
] rc-absolute-ppc-2/2 rt-literal 1 jit-push-literal jit-define

[
    0 temp-reg LOAD32                          ! load primitive address
    4 1 MR                                     ! pass stack pointer to primitive
    temp-reg MTCTR                             ! jump to primitive
    BCTR
] rc-absolute-ppc-2/2 rt-primitive 1 jit-primitive jit-define

[
    0 BL
] rc-relative-ppc-3 rt-xt 0 jit-word-call jit-define

[
    0 B
] rc-relative-ppc-3 rt-xt 0 jit-word-jump jit-define

: jit-call-quot ( -- )
    temp-reg quot-reg quot-xt@ LWZ             ! load quotation-xt
    temp-reg MTCTR                             ! jump to quotation-xt
    BCTR ;

[
    0 quot-reg LOAD32                          ! point quot-reg at false branch
    temp-reg ds-reg 0 LWZ                      ! load boolean
    0 temp-reg \ f tag-number CMPI             ! compare it with f
    2 BNE                                      ! skip next insn if its not f
    quot-reg dup 4 ADDI                        ! point quot-reg at true branch
    quot-reg dup 0 LWZ                         ! load the branch
    ds-reg dup 4 SUBI                          ! pop boolean
    jit-call-quot
] rc-absolute-ppc-2/2 rt-literal 1 jit-if-jump jit-define

[
    0 quot-reg LOAD32                          ! load dispatch array
    quot-reg dup 0 LWZ                         ! indirection
    temp-reg ds-reg 0 LWZ                      ! load index
    temp-reg dup 1 SRAWI                       ! turn it into an array offset
    quot-reg dup temp-reg ADD                  ! compute quotation location
    quot-reg dup array-start LWZ               ! load quotation
    ds-reg dup 4 SUBI                          ! pop index
    jit-call-quot
] rc-absolute-ppc-2/2 rt-literal 1 jit-dispatch jit-define

[
    0 1 lr-save stack-frame + LWZ              ! load return address
    1 1 stack-frame ADDI                       ! pop stack frame
    0 MTLR                                     ! get ready to return
] f f f jit-epilog jit-define

[ BLR ] f f f jit-return jit-define

[ "bootstrap.ppc" forget-vocab ] with-compilation-unit
