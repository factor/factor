! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: bootstrap.image.private kernel namespaces system
cpu.ppc.assembler math math.functions layouts words vocabs ;
IN: bootstrap.ppc

4 \ cell set
big-endian on

4 jit-code-format set

: ds-reg 14 ;

: word-reg 3 ;
: quot-reg 3 ;
: scan-reg 5 ;
: temp-reg 6 ;
: xt-reg 11 ;

: factor-area-size 4 bootstrap-cells ;

: stack-frame
    factor-area-size c-area-size + 4 bootstrap-cells align ;

: next-save stack-frame bootstrap-cell - ;
: xt-save stack-frame 2 bootstrap-cells - ;
: array-save stack-frame 3 bootstrap-cells - ;
: scan-save stack-frame 4 bootstrap-cells - ;

[
    temp-reg quot-reg quot-array@ LWZ          ! load array
    scan-reg temp-reg scan@ ADDI               ! initialize scan pointer
] { } make jit-setup set

[
    0 MFLR
    1 1 stack-frame neg ADDI
    xt-reg 1 xt-save STW                       ! save XT
    stack-frame xt-reg LI
    xt-reg 1 next-save STW                     ! save frame size
    temp-reg 1 array-save STW                  ! save array
    0 1 lr-save stack-frame + STW              ! save return address
] { } make jit-prolog set

[
    temp-reg scan-reg 4 LWZU                   ! load literal and advance
    temp-reg ds-reg 4 STWU                     ! push literal
] { } make jit-push-literal set

[
    temp-reg scan-reg 4 LWZU                   ! load wrapper and advance
    temp-reg dup wrapper@ LWZ                  ! load wrapped object
    temp-reg ds-reg 4 STWU                     ! push wrapped object
] { } make jit-push-wrapper set

[
    4 1 MR                                     ! pass stack pointer to primitive
] { } make jit-word-primitive-jump set

[
    4 1 MR                                     ! pass stack pointer to primitive
] { } make jit-word-primitive-call set

: load-xt ( -- )
    xt-reg word-reg word-xt@ LWZ ;

: jit-call
    scan-reg 1 scan-save STW                   ! save scan pointer
    xt-reg MTLR                                ! pass XT to callee
    BLRL                                       ! call
    scan-reg 1 scan-save LWZ                   ! restore scan pointer
    ;

: jit-jump
    xt-reg MTCTR BCTR ;

[
    word-reg scan-reg 4 LWZU                   ! load word and advance
    load-xt
    jit-call
] { } make jit-word-call set

[
    word-reg scan-reg 4 LWZ                    ! load word
    load-xt                                    ! jump to word XT
    jit-jump
] { } make jit-word-jump set

: load-branch
    temp-reg ds-reg 0 LWZ                      ! load boolean
    0 temp-reg \ f tag-number CMPI             ! compare it with f
    quot-reg scan-reg MR                       ! point quot-reg at false branch
    2 BNE                                      ! skip next insn if its not f
    quot-reg dup 4 ADDI                        ! point quot-reg at true branch
    quot-reg dup 4 LWZ                         ! load the branch
    ds-reg dup 4 SUBI                          ! pop boolean
    scan-reg dup 12 ADDI                       ! advance scan pointer
    xt-reg quot-reg quot-xt@ LWZ               ! load quotation-xt
    ;

[
    load-branch jit-jump
] { } make jit-if-jump set

[
    load-branch jit-call
] { } make jit-if-call set

[
    temp-reg ds-reg 0 LWZ                      ! load index
    temp-reg dup 1 SRAWI                       ! turn it into an array offset
    ds-reg dup 4 SUBI                          ! pop index
    scan-reg dup 4 LWZ                         ! load array
    temp-reg dup scan-reg ADD                  ! compute quotation location
    quot-reg temp-reg array-start LWZ          ! load quotation
    xt-reg quot-reg quot-xt@ LWZ               ! load quotation-xt
    jit-jump                                   ! execute quotation
] { } make jit-dispatch set

[
    0 1 lr-save stack-frame + LWZ              ! load return address
    1 1 stack-frame ADDI                       ! pop stack frame
    0 MTLR                                     ! get ready to return
] { } make jit-epilog set

[ BLR ] { } make jit-return set

"bootstrap.ppc" forget-vocab
