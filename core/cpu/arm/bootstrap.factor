! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: bootstrap.image.private kernel namespaces system
cpu.arm.assembler math math.functions layouts words vocabs ;
IN: bootstrap.arm

4 \ cell set
big-endian off

4 jit-code-format set

: ds-reg R5 ;

: word-reg R0 ;
: quot-reg R0 ;
: scan-reg R2 ;
: temp-reg R3 ;
: xt-reg R12 ;

: lr-save bootstrap-cell ;

: stack-frame 8 bootstrap-cells ;

: next-save stack-frame bootstrap-cell - ;
: xt-save stack-frame 2 bootstrap-cells - ;
: array-save stack-frame 3 bootstrap-cells - ;
: scan-save stack-frame 4 bootstrap-cells - ;

[
    temp-reg quot-reg quot-array@ <+> LDR      ! load array
    scan-reg temp-reg scan@ ADD                ! initialize scan pointer
] { } make jit-setup set

[
    SP SP stack-frame SUB
    xt-reg SP xt-save <+> STR                  ! save XT
    xt-reg stack-frame MOV
    xt-reg SP next-save <+> STR                ! save frame size
    temp-reg SP array-save <+> STR             ! save array
    LR SP lr-save stack-frame + <+> STR        ! save return address
] { } make jit-prolog set

[
    temp-reg scan-reg 4 <!+> LDR               ! load literal and advance
    temp-reg ds-reg 4 <!+> STR                 ! push literal
] { } make jit-push-literal set

[
    temp-reg scan-reg 4 <!+> LDR               ! load wrapper and advance
    temp-reg dup wrapper@ <+> LDR              ! load wrapped object
    temp-reg ds-reg 4 <!+> STR                 ! push wrapped object
] { } make jit-push-wrapper set

[
    R1 SP MOV                                  ! pass stack pointer to primitive
] { } make jit-word-primitive-jump set

[
    R1 SP MOV                                  ! pass stack pointer to primitive
] { } make jit-word-primitive-call set

: load-word-xt ( -- )
    word-reg scan-reg 4 <!+> LDR               ! load word and advance
    xt-reg word-reg word-xt@ <+> LDR ;

: jit-call
    scan-reg SP scan-save <+> STR              ! save scan pointer
    LR PC MOV                                  ! save return address
    PC xt-reg MOV                              ! call
    scan-reg SP scan-save <+> LDR              ! restore scan pointer
    ;

: jit-jump
    PC xt-reg MOV ;

[ load-word-xt jit-call ] { } make jit-word-call set

[ load-word-xt jit-jump ] { } make jit-word-jump set

: load-quot-xt
    xt-reg quot-reg quot-xt@ <+> LDR ;

: load-branch
    temp-reg ds-reg -4 <-!> LDR                ! pop boolean
    temp-reg \ f tag-number CMP                ! compare it with f
    scan-reg quot-reg MOV                      ! point quot-reg at false branch
    quot-reg dup 4 NE ADD                      ! point quot-reg at true branch
    quot-reg dup 4 <+> LDR                     ! load the branch
    scan-reg dup 12 ADD                        ! advance scan pointer
    load-quot-xt
    ;

[
    load-branch jit-jump
] { } make jit-if-jump set

[
    load-branch jit-call
] { } make jit-if-call set

[
    temp-reg ds-reg 4 <-!> LDR                 ! pop index
    temp-reg dup 1 <LSR> MOV                   ! turn it into an array offset
    scan-reg dup 4 <+> LDR                     ! load array
    temp-reg dup scan-reg ADD                  ! compute quotation location
    quot-reg temp-reg array-start <+> LDR      ! load quotation
    load-quot-xt
    jit-jump
] { } make jit-dispatch set

[
    SP SP stack-frame ADD                      ! pop stack frame
    LR SP lr-save stack-frame + <+> LDR        ! load return address
] { } make jit-epilog set

[ PC LR MOV ] { } make jit-return set

"bootstrap.arm" forget-vocab
