! Copyright (C) 2020 Doug Coleman.
! Copyright (C) 2023 Giftpflanze.
! See https://factorcode.org/license.txt for BSD license.
USING: bootstrap.image.private compiler.codegen.relocation
compiler.constants compiler.units cpu.arm.64.assembler
generic.single.private kernel kernel.private layouts
locals.backend math math.private namespaces slots.private
strings.private threads.private vocabs ;
IN: bootstrap.assembler.arm

big-endian off

8 \ cell set
: stack-frame-size ( -- n ) 8 bootstrap-cells ; inline

[
    FP LR SP stack-frame-size neg [pre] STP
    FP SP MOV
] JIT-PROLOG jit-define

: jit-save-context ( -- )
    ! The reason for -16 I think is because we are anticipating a CALL
    ! instruction. After the call instruction, the contexts frame_top
    ! will point to the origin jump address.
    temp SP MOV
    ! temp SP 16 SUB
    temp CTX context-callstack-top-offset [+] STR
    DS CTX context-datastack-offset [+] STR
    RS CTX context-retainstack-offset [+] STR ;

: jit-restore-context ( -- )
    DS CTX context-datastack-offset [+] LDR
    RS CTX context-retainstack-offset [+] LDR ;

[
    jit-save-context
    arg1 VM MOV
    f LDR=BLR rel-dlsym
    jit-restore-context
] JIT-PRIMITIVE jit-define

[
    [ PIC-TAIL swap ADR ] [
        LDR=BR rel-word-pic-tail
    ] jit-conditional*
] JIT-WORD-JUMP jit-define

[
    LDR=BLR rel-word-pic
] JIT-WORD-CALL jit-define

[
    ds-0 DS -8 [post] LDR
    ds-0 \ f type-number CMP
    ! skip over true branch if equal
    [ BEQ ] [
        ! jump to true branch
        LDR=BR rel-word
    ] jit-conditional*
    ! jump to false branch
    LDR=BR rel-word
] JIT-IF jit-define

[
    SAFEPOINT dup [] STR
] JIT-SAFEPOINT jit-define

[
    FP LR SP stack-frame-size [post] LDP
] JIT-EPILOG jit-define

[
    RET
] JIT-RETURN jit-define

[
    ds-0 LDR= rel-literal
    ds-0 DS 8 [pre] STR
] JIT-PUSH-LITERAL jit-define

: >r ( -- )
    ds-0 DS -8 [post] LDR
    ds-0 RS 8 [pre] STR ;

: r> ( -- )
    ds-0 RS -8 [post] LDR
    ds-0 DS 8 [pre] STR ;

[
    >r
    LDR=BLR rel-word
    r>
] JIT-DIP jit-define

[
    >r >r
    LDR=BLR rel-word
    r> r>
] JIT-2DIP jit-define

[
    >r >r >r
    LDR=BLR rel-word
    r> r> r>
] JIT-3DIP jit-define

[
    ! arg1 is a surprise tool that will be important later
    arg1 DS -8 [post] LDR
    temp arg1 quot-entry-point-offset [+] LDR
]
[ temp BLR ]
[ temp BR ]
\ (call) define-combinator-primitive

[
    temp DS -8 [post] LDR
    temp dup word-entry-point-offset [+] LDR
]
[ temp BLR ]
[ temp BR ]
\ (execute) define-combinator-primitive

[
    temp DS -8 [post] LDR
    temp dup word-entry-point-offset [+] LDR
    temp BR
] JIT-EXECUTE jit-define

[
    arg2 arg1 MOV
    arg1 VM MOV
    "begin_callback" LDR=BLR rel-dlsym

    temp RETURN quot-entry-point-offset [+] LDR
    temp BLR

    arg1 VM MOV
    "end_callback" LDR=BLR rel-dlsym
] \ c-to-factor define-sub-primitive

[
    jit-save-context
    arg2 VM MOV
    "lazy_jit_compile" LDR=BLR rel-dlsym
    temp RETURN quot-entry-point-offset [+] LDR
]
[ temp BLR ]
[ temp BR ]
\ lazy-jit-compile define-combinator-primitive

{
    { unwind-native-frames [
        SP arg2 MOV
        VM LDR= rel-vm
        CTX VM vm-context-offset [+] LDR
        jit-restore-context
        XZR VM vm-fault-flag-offset [+] STR
        temp arg1 quot-entry-point-offset [+] LDR
        temp BR
    ] }
    { fpu-state [ FPSR XZR MSR ] }
    { set-fpu-state [ ] }
} define-sub-primitives

: jit-signal-handler-prolog ( -- )
    X0 X1 SP -16 [pre] STP
    X2 X3 SP -16 [pre] STP
    X4 X5 SP -16 [pre] STP
    X6 X7 SP -16 [pre] STP
    X8 X9 SP -16 [pre] STP
    X10 X11 SP -16 [pre] STP
    X12 X13 SP -16 [pre] STP
    X14 X15 SP -16 [pre] STP
    X16 X17 SP -16 [pre] STP
    X18 X19 SP -16 [pre] STP
    X20 X21 SP -16 [pre] STP
    X22 X23 SP -16 [pre] STP
    X24 X25 SP -16 [pre] STP
    X26 X27 SP -16 [pre] STP
    X28 X29 SP -16 [pre] STP
    X0 NZCV MRS
    X30 X0 SP -16 [pre] STP
    SP dup 4 bootstrap-cells SUB ;

: jit-signal-handler-epilog ( -- )
    SP dup 4 bootstrap-cells ADD
    X30 X0 SP 16 [post] LDP
    NZCV X0 MSR
    X28 X29 SP 16 [post] LDP
    X26 X27 SP 16 [post] LDP
    X24 X25 SP 16 [post] LDP
    X22 X23 SP 16 [post] LDP
    X20 X21 SP 16 [post] LDP
    X18 X19 SP 16 [post] LDP
    X16 X17 SP 16 [post] LDP
    X14 X15 SP 16 [post] LDP
    X12 X13 SP 16 [post] LDP
    X10 X11 SP 16 [post] LDP
    X8 X9 SP 16 [post] LDP
    X6 X7 SP 16 [post] LDP
    X4 X6 SP 16 [post] LDP
    X2 X3 SP 16 [post] LDP
    X0 X1 SP 16 [post] LDP ;

{
    { signal-handler [
        jit-signal-handler-prolog
        jit-save-context
        temp VM vm-signal-handler-addr-offset [+] LDR
        temp BLR
        jit-signal-handler-epilog
        FP LR SP 16 [post] LDP
        RET
    ] }
    { leaf-signal-handler [
        jit-signal-handler-prolog
        jit-save-context
        temp VM vm-signal-handler-addr-offset [+] LDR
        temp BLR
        jit-signal-handler-epilog
        FP LR SP leaf-stack-frame-size [post] LDP
        RET
    ] }
} define-sub-primitives
! C to Factor entry point
[
    ! Save all non-volatile registers
    X18 X19 SP -16 [pre] STP
    X20 X21 SP -16 [pre] STP
    X22 X23 SP -16 [pre] STP
    X24 X25 SP -16 [pre] STP
    X26 X27 SP -16 [pre] STP
    X28 X29 SP -16 [pre] STP
    X30     SP -16 [pre] STR
    FP SP MOV

    jit-save-teb

    VM LDR= rel-vm
    SAFEPOINT (LDR=) rel-safepoint
    MEGA-HITS (LDR=) rel-megamorphic-cache-hits
    CACHE-MISS (LDR=) rel-inline-cache-miss
    CARDS-OFFSET (LDR=) rel-cards-offset
    DECKS-OFFSET (LDR=) rel-decks-offset

    ! Save old context
    CTX VM vm-context-offset [+] LDR
    CTX SP 8 [+] STR

    ! Switch over to the spare context
    CTX VM vm-spare-context-offset [+] LDR
    CTX VM vm-context-offset [+] STR

    ! Save C callstack pointer
    temp SP MOV
    temp CTX context-callstack-save-offset [+] STR

    ! Load Factor stack pointers
    temp CTX context-callstack-bottom-offset [+] LDR
    SP temp MOV

    jit-update-teb

    RS CTX context-retainstack-offset [+] LDR
    DS CTX context-datastack-offset [+] LDR

    ! Call into Factor code
    LDR=BLR rel-word

    ! Load C callstack pointer
    CTX VM vm-context-offset [+] LDR

    temp CTX context-callstack-save-offset [+] LDR
    SP temp MOV

    ! Load old context
    CTX SP 8 [+] LDR
    CTX VM vm-context-offset [+] STR

    jit-restore-teb

    ! Restore non-volatile registers
    X30     SP 16 [post] LDR
    X28 X29 SP 16 [post] LDP
    X26 X27 SP 16 [post] LDP
    X24 X25 SP 16 [post] LDP
    X22 X23 SP 16 [post] LDP
    X20 X21 SP 16 [post] LDP
    X18 X19 SP 16 [post] LDP
    RET
] CALLBACK-STUB jit-define

! Polymorphic inline caches

[
    obj DS [] LDUR f rc-absolute-arm-ldur rel-untagged
] PIC-LOAD jit-define

[
    type obj tag-mask get ANDS
] PIC-TAG jit-define

[
    type obj tag-mask get AND
    type tuple type-number CMP
    [ BNE ] [
        type obj tuple-class-offset [+] LDR
    ] jit-conditional*
] PIC-TUPLE jit-define

[
    type 0 CMP f rc-absolute-arm-cmp rel-untagged
] PIC-CHECK-TAG jit-define

[
    temp LDR= rel-literal
    type temp CMP
] PIC-CHECK-TUPLE jit-define

[
    [ BNE ] [
        LDR=BR rel-word
    ] jit-conditional*
] PIC-HIT jit-define

: jit-load-return-address ( -- )
    PIC-TAIL SP 8 [+] LDR
    PIC-TAIL dup 3 insns ADD ;

: jit-inline-cache-miss ( -- )
    jit-save-context
    arg1 PIC-TAIL MOV
    arg2 VM MOV
    CACHE-MISS BLR
    jit-restore-context ;

[ jit-load-return-address jit-inline-cache-miss ]
[ RETURN BLR ]
[ RETURN BR ]
\ inline-cache-miss define-combinator-primitive

[ jit-inline-cache-miss ]
[ RETURN BLR ]
[ RETURN BR ]
\ inline-cache-miss-tail define-combinator-primitive

! Megamorphic caches

[
    ! class = ...
    type obj tag-bits get dup UBFIZ
    type tuple type-number tag-fixnum CMP
    [ BNE ] [
        type obj tuple-class-offset [+] LDR
    ] jit-conditional*
    ! cache = ...
    cache LDR= rel-literal
    ! key = hashcode(class) & mask
    temp type mega-cache-size get 1 - bootstrap-cells AND
    ! cache += key
    cache dup temp ADD
    ! if(get(cache) == class)
    temp cache array-start-offset [+] LDR
    type temp CMP
    [ BNE ] [
        ! megamorphic_cache_hits++
        temp MEGA-HITS [] LDR
        temp dup 1 ADD
        temp MEGA-HITS [] STR
        ! goto get(cache + bootstrap-cell)
        temp cache array-start-offset bootstrap-cell + [+] LDR
        temp dup word-entry-point-offset [+] LDR
        temp BR
        ! fall-through on miss
    ] jit-conditional*
] MEGA-LOOKUP jit-define

! Contexts
: jit-switch-context ( -- )
    ! Push a bogus return address so the GC can track this frame back
    ! to the owner
    ! temp 0 ADR
    ! FP temp SP -16 [pre] STP

    ! Make the new context the current one
    CTX VM vm-context-offset [+] STR

    ! Load new stack pointer
    temp CTX context-callstack-top-offset [+] LDR
    SP temp MOV

    ! Load new ds, rs registers
    jit-restore-context

    jit-update-teb ;

: jit-set-context ( -- )
    ds-0 DS -8 [post] LDR
    ds-0 dup alien-offset [+] LDR
    ds-1 DS -8 [post] LDR
    jit-save-context
    CTX ds-0 MOV
    jit-switch-context
    ! SP dup 16 ADD
    ds-1 DS 8 [pre] STR ;

: jit-delete-current-context ( -- )
    arg1 VM MOV
    "delete_context" LDR=BLR rel-dlsym ;

: jit-start-context ( -- )
    ! Create the new context in RETURN. Have to save context
    ! twice, first before calling new_context() which may GC,
    ! and again after popping the two parameters from the stack.
    jit-save-context
    arg1 VM MOV
    "new_context" LDR=BLR rel-dlsym

    ds-0 DS -8 [post] LDR
    ds-1 DS -8 [post] LDR
    jit-save-context
    CTX RETURN MOV
    jit-switch-context
    ds-1 DS 8 [pre] STR
    ! arg1 is a surprise tool that will be important later
    arg1 ds-0 MOV
    temp arg1 quot-entry-point-offset [+] LDR
    temp BR ;

! Resets the active context and instead the passed in quotation
! becomes the new code that it executes.
: jit-start-context-and-delete ( -- )
    ! Updates the context to match the values in the data and retain
    ! stack registers. reset_context can GC.
    jit-save-context

    ! Resets the context. The top two ds items are preserved.
    arg1 VM MOV
    "reset_context" LDR=BLR rel-dlsym

    ! Switches to the same context I think.
    jit-switch-context

    ds-0 DS -8 [post] LDR
    temp ds-0 quot-entry-point-offset [+] LDR
    temp BR ;

: jit-compare ( cond -- )
    t temp1 (LDR=) rel-literal
    temp2 \ f type-number MOV
    ds-1 ds-0 DS -8 [pre] LDP
    ds-1 ds-0 CMP
    [ ds-0 temp1 temp2 ] dip CSEL
    ds-0 DS [] STR ;

{
    { (set-context) [ jit-set-context ] }
    { (set-context-and-delete) [
        jit-delete-current-context
        jit-set-context
    ] }
    { (start-context) [ jit-start-context ] }
    { (start-context-and-delete) [ jit-start-context-and-delete ] }

    { fixnum+fast [
        ds-1 ds-0 DS -8 [pre] LDP
        ds-0 ds-1 ds-0 ADD
        ds-0 DS [] STR
    ] }
    { fixnum-fast [
        ds-1 ds-0 DS -8 [pre] LDP
        ds-0 ds-1 ds-0 SUB
        ds-0 DS [] STR
    ] }
    { fixnum*fast [
        ds-1 ds-0 DS -8 [pre] LDP
        ds-0 dup tag-bits get ASR
        ds-0 dup ds-1 MUL
        ds-0 DS [] STR
    ] }

    { fixnum+ [
        arg1 arg2 DS -8 [pre] LDP
        jit-save-context
        ds-0 arg1 arg2 ADDS
        ds-0 DS [] STR
        [ BVC ] [
            arg3 VM MOV
            "overflow_fixnum_add" LDR=BLR rel-dlsym
        ] jit-conditional*
    ] }
    { fixnum- [
        arg1 arg2 DS -8 [pre] LDP
        jit-save-context
        ds-0 arg1 arg2 SUBS
        ds-0 DS [] STR
        [ BVC ] [
            arg3 VM MOV
            "overflow_fixnum_subtract" LDR=BLR rel-dlsym
        ] jit-conditional*
    ] }
    { fixnum* [
        arg1 arg2 DS -8 [pre] LDP
        jit-save-context
        arg1 dup tag-bits get ASR
        ds-0 arg1 arg2 MUL
        ds-0 DS [] STR
        ds-0 dup 63 ASR
        temp arg1 arg2 SMULH
        ds-0 temp CMP
        [ BEQ ] [
            arg2 dup tag-bits get ASR
            arg3 VM MOV
            "overflow_fixnum_multiply" LDR=BLR rel-dlsym
        ] jit-conditional*
    ] }

    { fixnum/i-fast [
        ds-1 ds-0 DS -8 [pre] LDP
        quotient ds-1 ds-0 SDIV
        quotient dup tag-bits get LSL
        quotient DS [] STR
    ] }
    { fixnum-mod [
        ds-1 ds-0 DS -8 [pre] LDP
        quotient ds-1 ds-0 SDIV
        remainder ds-0 quotient ds-1 MSUB
        remainder DS [] STR
    ] }
    { fixnum/mod-fast [
        ds-1 ds-0 DS -8 [+] LDP
        quotient ds-1 ds-0 SDIV
        remainder ds-0 quotient ds-1 MSUB
        quotient dup tag-bits get LSL
        quotient remainder DS -8 [+] STP
    ] }

    { both-fixnums? [
        ds-1 ds-0 DS -8 [pre] LDP
        ds-0 dup ds-1 ORR
        ds-0 tag-mask get TST
        temp1 1 tag-fixnum MOV
        temp2 \ f type-number MOV
        ds-0 temp1 temp2 EQ CSEL
        ds-0 DS [] STR
    ] }

    { eq? [ EQ jit-compare ] }
    { fixnum> [ GT jit-compare ] }
    { fixnum>= [ GE jit-compare ] }
    { fixnum< [ LT jit-compare ] }
    { fixnum<= [ LE jit-compare ] }

    { fixnum-bitnot [
        ds-0 DS [] LDR
        ds-0 dup tag-mask get bitnot EOR
        ds-0 DS [] STR
    ] }
    { fixnum-bitand [
        ds-1 ds-0 DS -8 [pre] LDP
        ds-0 ds-1 ds-0 AND
        ds-0 DS [] STR
    ] }
    { fixnum-bitor [
        ds-1 ds-0 DS -8 [pre] LDP
        ds-0 ds-1 ds-0 ORR
        ds-0 DS [] STR
    ] }
    { fixnum-bitxor [
        ds-1 ds-0 DS -8 [pre] LDP
        ds-0 ds-1 ds-0 EOR
        ds-0 DS [] STR
    ] }
    { fixnum-shift-fast [
        ds-1 ds-0 DS -8 [pre] LDP
        ds-0 dup tag-bits get ASR
        ! compute positive shift value in temp1
        temp1 ds-1 ds-0 LSL
        ! compute negative shift value in temp2
        ds-0 dup NEGS
        temp2 ds-1 ds-0 ASR
        temp2 dup tag-mask get bitnot AND
        ! if shift count was positive, choose temp1
        ds-0 temp1 temp2 MI CSEL
        ds-0 DS [] STR
    ] }

    { drop-locals [
        ds-0 DS -8 [post] LDR
        RS dup ds-0 tag-bits get 3 - <ASR> SUB
    ] }
    { get-local [
        ds-0 DS [] LDR
        ds-0 dup tag-bits get 3 - ASR
        ds-0 RS ds-0 [+] LDR
        ds-0 DS [] STR
    ] }
    { load-local [ >r ] }

    { slot [
        ds-1 ds-0 DS -8 [pre] LDP
        ds-0 dup tag-bits get 3 - ASR
        ds-1 dup tag-mask get bitnot AND
        ds-0 dup ds-1 [+] LDR
        ds-0 DS [] STR
    ] }
    { string-nth-fast [
        ds-1 ds-0 DS -8 [pre] LDP
        ds-0 dup ds-1 tag-bits get <ASR> ADD
        ds-0 dup string-offset [+] LDRB
        ds-0 dup tag-bits get LSL
        ds-0 DS [] STR
    ] }
    { tag [
        ds-0 DS [] LDR
        ds-0 dup tag-bits get dup UBFIZ
        ds-0 DS [] STR
    ] }

    { drop [ DS dup 8 SUB ] }
    { 2drop [ DS dup 16 SUB ] }
    { 3drop [ DS dup 24 SUB ] }
    { 4drop [ DS dup 32 SUB ] }
    { dup [
        ds-0 DS [] LDR
        ds-0 DS 8 [pre] STR
    ] }
    { 2dup [
        ds-1 ds-0 DS -8 [+] LDP
        ds-1 DS 8 [pre] STR
        ds-0 DS 8 [pre] STR
    ] }
    { 3dup [
        ds-2 DS -16 [+] LDR
        ds-1 ds-0 DS -8 [+] LDP
        ds-2 ds-1 DS 8 [pre] STP
        ds-0 DS 16 [pre] STR
    ] }
    { 4dup [
        ds-3 ds-2 DS -24 [+] LDP
        ds-1 ds-0 DS -8 [+] LDP
        ds-3 ds-2 DS 8 [pre] STP
        ds-1 DS 16 [pre] STR
        ds-0 DS 8 [pre] STR
    ] }
    { dupd [
        ds-1 ds-0 DS -8 [+] LDP
        ds-1 DS [] STR
        ds-0 DS 8 [pre] STR
    ] }
    { over [
        ds-1 DS -8 [+] LDR
        ds-1 DS 8 [pre] STR
    ] }
    { pick [
        ds-2 DS -16 [+] LDR
        ds-2 DS 8 [pre] STR
    ] }
    { nip [
        ds-0 DS [] LDR
        ds-0 DS -8 [pre] STR
    ] }
    { 2nip [
        ds-0 DS [] LDR
        ds-0 DS -16 [pre] STR
    ] }
    { -rot [
        ds-0 DS -8 [post] LDR
        ds-2 ds-1 DS -8 [+] LDP
        ds-0 ds-2 DS -8 [+] STP
        ds-1 DS 8 [pre] STR
    ] }
    { rot [
        ds-0 DS -8 [post] LDR
        ds-2 ds-1 DS -8 [+] LDP
        ds-1 ds-0 DS -8 [+] STP
        ds-2 DS 8 [pre] STR
    ] }
    { swap [
        ds-1 ds-0 DS -8 [+] LDP
        ds-0 ds-1 DS -8 [+] STP
    ] }
    { swapd [
        ds-2 ds-1 DS -16 [+] LDP
        ds-1 ds-2 DS -16 [+] STP
    ] }

    { set-callstack [
        ds-0 DS -8 [post] LDR
        ! Get ctx->callstack_bottom
        arg1 CTX context-callstack-bottom-offset [+] LDR
        ! Get top of callstack object -- 'src' for memcpy
        arg2 ds-0 callstack-top-offset ADD
        ! Get callstack length, in bytes --- 'len' for memcpy
        arg3 ds-0 callstack-length-offset [+] LDR
        arg3 dup tag-bits get LSR
        ! Compute new stack pointer -- 'dst' for memcpy
        arg1 dup arg3 SUB
        ! Install new stack pointer
        SP arg1 MOV
        ! Call memcpy; arguments are now in the correct registers
        ! Create register shadow area for Win64
        SP dup 32 SUB
        "factor_memcpy" LDR=BLR rel-dlsym
        ! Tear down register shadow area
        SP dup 32 ADD
        ! Return with new callstack
        FP LR SP stack-frame-size [post] LDP
        RET
    ] }
} define-sub-primitives

[ "bootstrap.assembler.arm" forget-vocab ] with-compilation-unit
