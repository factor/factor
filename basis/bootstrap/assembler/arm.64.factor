! Copyright (C) 2025 Giftpflanze.
! See https://factorcode.org/license.txt for BSD license.
USING: bootstrap.image.private compiler.codegen.relocation
compiler.constants compiler.units cpu.arm.64.assembler
cpu.arm.64.assembler.registers generic.single.private kernel
kernel.private layouts locals.backend math math.private
namespaces slots.private strings.private threads.private vocabs
;
FROM: cpu.arm.64.assembler => B ;
IN: bootstrap.assembler.arm

big-endian off

[
    FP LR SP -16 [pre] STP
    FP SP MOV
] JIT-PROLOG jit-define

[
    DS RS CTX context-datastack-offset [+] STP
    arg1 VM MOV
    f LDR=BLR*
    DS RS CTX context-datastack-offset [+] LDP
] JIT-PRIMITIVE jit-define

[
    PIC-TAIL 2 insns ADR
    0 B f rc-relative-arm-b rel-word-pic-tail
] JIT-WORD-JUMP jit-define

[
    0 BL f rc-relative-arm-b rel-word-pic
] JIT-WORD-CALL jit-define

[
    ds-0 DS -8 [post] LDR
    ds-0 \ f type-number CMP
    [ BEQ ] [
        0 B f rc-relative-arm-b rel-word
    ] jit-conditional*
    0 B f rc-relative-arm-b rel-word
] JIT-IF jit-define

[
    SAFEPOINT dup [] STR
] JIT-SAFEPOINT jit-define

[
    FP LR SP 16 [post] LDP
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
    0 BL f rc-relative-arm-b rel-word
    r>
] JIT-DIP jit-define

[
    >r >r
    0 BL f rc-relative-arm-b rel-word
    r> r>
] JIT-2DIP jit-define

[
    >r >r >r
    0 BL f rc-relative-arm-b rel-word
    r> r> r>
] JIT-3DIP jit-define

[
    temp DS -8 [post] LDR
    temp dup word-entry-point-offset [+] LDR
    temp BR
] JIT-EXECUTE jit-define

[
    X18 X19 SP -16 [pre] STP
    X20 X21 SP -16 [pre] STP
    X22 X23 SP -16 [pre] STP
    X24 X25 SP -16 [pre] STP
    X26 X27 SP -16 [pre] STP
    X28 X29 SP -16 [pre] STP
    0 VM (LDR=) rel-vm
    CTX VM vm-context-offset [+] LDR
    X30 CTX SP -16 [pre] STP
    SAFEPOINT (LDR=) rel-safepoint
    TRAMPOLINE (LDR=) rel-trampoline
    CACHE-MISS (LDR=) rel-inline-cache-miss
    MEGA-HITS (LDR=) rel-megamorphic-cache-hits
    CTX VM vm-spare-context-offset [+] LDR
    CTX VM vm-context-offset [+] STR
    temp SP MOV
    temp CTX context-callstack-save-offset [+] STR
    jit-save-teb
    temp CTX context-callstack-bottom-offset [+] LDR
    SP temp MOV
    FP XZR MOV
    jit-update-teb
    DS RS CTX context-datastack-offset [+] LDP
    LDR=BLR rel-word
    temp CTX context-callstack-save-offset [+] LDR
    SP temp MOV
    jit-restore-teb
    X30 CTX SP 16 [post] LDP
    CTX VM vm-context-offset [+] STR
    X28 X29 SP 16 [post] LDP
    X26 X27 SP 16 [post] LDP
    X24 X25 SP 16 [post] LDP
    X22 X23 SP 16 [post] LDP
    X20 X21 SP 16 [post] LDP
    X18 X19 SP 16 [post] LDP
    RET
] CALLBACK-STUB jit-define

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
        0 B f rc-relative-arm-b rel-word
    ] jit-conditional*
] PIC-HIT jit-define

[
    type obj tag-bits get dup UBFIZ
    type tuple type-number tag-fixnum CMP
    [ BNE ] [
        type obj tuple-class-offset [+] LDR
    ] jit-conditional*
    cache LDR= rel-literal
    temp type mega-cache-size get 1 - bootstrap-cells AND
    cache dup temp ADD
    temp cache array-start-offset [+] LDR
    type temp CMP
    [ BNE ] [
        temp MEGA-HITS [] LDR
        temp dup 1 ADD
        temp MEGA-HITS [] STR
        temp cache array-start-offset bootstrap-cell + [+] LDR
        temp dup word-entry-point-offset [+] LDR
        temp BR
    ] jit-conditional*
] MEGA-LOOKUP jit-define

[
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
    DS RS CTX context-datastack-offset [+] STP
    arg2 VM MOV
    "lazy_jit_compile" LDR=BLR*
    temp RETURN quot-entry-point-offset [+] LDR
]
[ temp BLR ]
[ temp BR ]
\ lazy-jit-compile define-combinator-primitive

[
    DS RS CTX context-datastack-offset [+] STP
    arg1 SP 8 [+] LDR
    arg2 VM MOV
    temp CACHE-MISS MOV
    TRAMPOLINE BLR
    DS RS CTX context-datastack-offset [+] LDP
]
[ RETURN BLR ]
[ RETURN BR ]
\ inline-cache-miss define-combinator-primitive

[
    DS RS CTX context-datastack-offset [+] STP
    arg1 PIC-TAIL MOV
    arg2 VM MOV
    temp CACHE-MISS MOV
    TRAMPOLINE BLR
    DS RS CTX context-datastack-offset [+] LDP
]
[ RETURN BLR ]
[ RETURN BR ]
\ inline-cache-miss-tail define-combinator-primitive

: (signal-handler) ( -- )
    X0  X1  SP -16 [pre] STP
    X2  X3  SP -16 [pre] STP
    X4  X5  SP -16 [pre] STP
    X6  X7  SP -16 [pre] STP
    X8  X9  SP -16 [pre] STP
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
    X30 X0  SP -16 [pre] STP
    DS RS CTX context-datastack-offset [+] STP
    temp VM vm-signal-handler-addr-offset [+] LDR
    temp BLR
    X30 X0  SP 16 [post] LDP
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
    X8  X9  SP 16 [post] LDP
    X6  X7  SP 16 [post] LDP
    X4  X5  SP 16 [post] LDP
    X2  X3  SP 16 [post] LDP
    X0  X1  SP 16 [post] LDP
    FP LR SP 16 [post] LDP
    RET ;

: jit-compare ( cond -- )
    t temp1 (LDR=) rel-literal
    temp2 \ f type-number MOV
    ds-1 ds-0 DS -8 [pre] LDP
    ds-1 ds-0 CMP
    [ ds-0 temp1 temp2 ] dip CSEL
    ds-0 DS [] STR ;

{
    { c-to-factor [
        arg2 arg1 MOV
        arg1 VM MOV
        "begin_callback" LDR=BLR rel-dlsym
        temp RETURN quot-entry-point-offset [+] LDR
        temp BLR
        arg1 VM MOV
        "end_callback" LDR=BLR rel-dlsym
    ] }
    { unwind-native-frames [
        SP arg2 MOV
        FP SP MOV
        0 VM (LDR=) rel-vm
        CTX VM vm-context-offset [+] LDR
        DS RS CTX context-datastack-offset [+] LDP
        SAFEPOINT (LDR=) rel-safepoint
        TRAMPOLINE (LDR=) rel-trampoline
        CACHE-MISS (LDR=) rel-inline-cache-miss
        MEGA-HITS (LDR=) rel-megamorphic-cache-hits
        XZR VM vm-fault-flag-offset [+] STR
        temp arg1 quot-entry-point-offset [+] LDR
        temp BR
    ] }
    { fpu-state [ FPSR XZR MSR ] }
    { set-fpu-state [ ] }
    { signal-handler [ (signal-handler) ] }
    { leaf-signal-handler [ (signal-handler) ] }

    { drop [ DS dup 8 SUB ] }
    { 2drop [ DS dup 16 SUB ] }
    { 3drop [ DS dup 24 SUB ] }
    { 4drop [ DS dup 32 SUB ] }
    { dup [
        ds-0 DS [] LDR
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
    { swap [
        ds-1 ds-0 DS -8 [+] LDP
        ds-0 ds-1 DS -8 [+] STP
    ] }
    { swapd [
        ds-2 ds-1 DS -16 [+] LDP
        ds-1 ds-2 DS -16 [+] STP
    ] }
    { nip [
        ds-0 DS [] LDR
        ds-0 DS -8 [pre] STR
    ] }
    { 2nip [
        ds-0 DS [] LDR
        ds-0 DS -16 [pre] STR
    ] }
    { 2dup [
        ds-1 ds-0 DS -8 [+] LDP
        ds-1 DS 8 [pre] STR
        ds-0 DS 8 [pre] STR
    ] }
    { dupd [
        ds-1 ds-0 DS -8 [+] LDP
        ds-1 DS [] STR
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
    { rot [
        ds-0 DS -8 [post] LDR
        ds-2 ds-1 DS -8 [+] LDP
        ds-1 ds-0 DS -8 [+] STP
        ds-2 DS 8 [pre] STR
    ] }
    { -rot [
        ds-0 DS -8 [post] LDR
        ds-2 ds-1 DS -8 [+] LDP
        ds-0 ds-2 DS -8 [+] STP
        ds-1 DS 8 [pre] STR
    ] }
    { eq? [ EQ jit-compare ] }
    { set-callstack [
        ds-0 DS -8 [post] LDR
        arg1 CTX context-callstack-bottom-offset [+] LDR
        arg2 ds-0 callstack-top-offset ADD
        arg3 ds-0 callstack-length-offset [+] LDR
        arg3 dup tag-bits get LSR
        arg1 dup arg3 SUB
        SP arg1 MOV
        FP SP MOV
        "factor_memcpy" LDR=BLR rel-dlsym
        top SP MOV
        *top top [] LDR
        *top 5 insns CBZ
        *top dup top ADD
        *top top [] STR
        top *top MOV
        -5 insns B
        FP LR SP [] LDP
        SP FP MOV
        RET
    ] }
    { tag [
        ds-0 DS [] LDR
        ds-0 dup tag-bits get dup UBFIZ
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

    { both-fixnums? [
        ds-1 ds-0 DS -8 [pre] LDP
        ds-0 dup ds-1 ORR
        ds-0 tag-mask get TST
        temp1 1 tag-fixnum MOV
        temp2 \ f type-number MOV
        ds-0 temp1 temp2 EQ CSEL
        ds-0 DS [] STR
    ] }
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
        DS RS CTX context-datastack-offset [+] STP
        ds-0 arg1 arg2 ADDS
        ds-0 DS [] STR
        [ BVC ] [
            arg3 VM MOV
            "overflow_fixnum_add" LDR=BLR*
        ] jit-conditional*
    ] }
    { fixnum- [
        arg1 arg2 DS -8 [pre] LDP
        DS RS CTX context-datastack-offset [+] STP
        ds-0 arg1 arg2 SUBS
        ds-0 DS [] STR
        [ BVC ] [
            arg3 VM MOV
            "overflow_fixnum_subtract" LDR=BLR*
        ] jit-conditional*
    ] }
    { fixnum* [
        arg1 arg2 DS -8 [pre] LDP
        DS RS CTX context-datastack-offset [+] STP
        arg1 dup tag-bits get ASR
        ds-0 arg1 arg2 MUL
        ds-0 DS [] STR
        ds-0 dup 63 ASR
        temp arg1 arg2 SMULH
        ds-0 temp CMP
        [ BEQ ] [
            arg2 dup tag-bits get ASR
            arg3 VM MOV
            "overflow_fixnum_multiply" LDR=BLR*
        ] jit-conditional*
    ] }
    { fixnum-bitand [
        ds-1 ds-0 DS -8 [pre] LDP
        ds-0 ds-1 ds-0 AND
        ds-0 DS [] STR
    ] }
    { fixnum-bitnot [
        ds-0 DS [] LDR
        ds-0 dup tag-mask get bitnot EOR
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
    { fixnum-mod [
        ds-1 ds-0 DS -8 [pre] LDP
        quotient ds-1 ds-0 SDIV
        remainder ds-0 quotient ds-1 MSUB
        remainder DS [] STR
    ] }
    { fixnum-shift-fast [
        ds-1 ds-0 DS -8 [pre] LDP
        ds-0 dup tag-bits get ASR
        temp1 ds-1 ds-0 LSL
        ds-0 dup NEGS
        temp2 ds-1 ds-0 ASR
        temp2 dup tag-mask get bitnot AND
        ds-0 temp1 temp2 MI CSEL
        ds-0 DS [] STR
    ] }
    { fixnum/i-fast [
        ds-1 ds-0 DS -8 [pre] LDP
        quotient ds-1 ds-0 SDIV
        quotient dup tag-bits get LSL
        quotient DS [] STR
    ] }
    { fixnum/mod-fast [
        ds-1 ds-0 DS -8 [+] LDP
        quotient ds-1 ds-0 SDIV
        remainder ds-0 quotient ds-1 MSUB
        quotient dup tag-bits get LSL
        quotient remainder DS -8 [+] STP
    ] }
    { fixnum< [ LT jit-compare ] }
    { fixnum<= [ LE jit-compare ] }
    { fixnum> [ GT jit-compare ] }
    { fixnum>= [ GE jit-compare ] }

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

    { (set-context) [
        ds-0 DS -8 [post] LDR
        ds-0 dup alien-offset [+] LDR
        ds-1 DS -8 [post] LDR
        temp 0 ADR
        FP temp SP -16 [pre] STP
        FP SP MOV
        FP CTX context-callstack-top-offset [+] STR
        DS RS CTX context-datastack-offset [+] STP
        CTX ds-0 MOV
        jit-update-teb
        CTX VM vm-context-offset [+] STR
        temp CTX context-callstack-top-offset [+] LDR
        FP temp [] LDR
        SP FP MOV
        DS RS CTX context-datastack-offset [+] LDP
        ds-1 DS 8 [pre] STR
    ] }
    { (set-context-and-delete) [
        arg1 VM MOV
        "delete_context" LDR=BLR rel-dlsym
        ds-0 DS -8 [post] LDR
        ds-0 dup alien-offset [+] LDR
        ds-1 DS -8 [post] LDR
        CTX ds-0 MOV
        jit-update-teb
        CTX VM vm-context-offset [+] STR
        temp CTX context-callstack-top-offset [+] LDR
        FP temp [] LDR
        SP FP MOV
        DS RS CTX context-datastack-offset [+] LDP
        ds-1 DS 8 [pre] STR
    ] }
    { (start-context) [
        DS RS CTX context-datastack-offset [+] STP
        arg1 VM MOV
        "new_context" LDR=BLR*
        ds-0 DS -8 [post] LDR
        ds-1 DS -8 [post] LDR
        temp 0 ADR
        FP temp SP -16 [pre] STP
        FP SP MOV
        FP CTX context-callstack-top-offset [+] STR
        DS RS CTX context-datastack-offset [+] STP
        CTX RETURN MOV
        jit-update-teb
        CTX VM vm-context-offset [+] STR
        temp CTX context-callstack-top-offset [+] LDR
        SP temp MOV
        FP XZR MOV
        DS RS CTX context-datastack-offset [+] LDP
        ds-1 DS 8 [pre] STR
        arg1 ds-0 MOV
        temp arg1 quot-entry-point-offset [+] LDR
        temp BR
    ] }
    { (start-context-and-delete) [
        DS RS CTX context-datastack-offset [+] STP
        arg1 VM MOV
        "reset_context" LDR=BLR*
        temp CTX context-callstack-top-offset [+] LDR
        SP temp MOV
        FP XZR MOV
        DS RS CTX context-datastack-offset [+] LDP
        arg1 DS -8 [post] LDR
        temp arg1 quot-entry-point-offset [+] LDR
        temp BR
    ] }
} define-sub-primitives

[ "bootstrap.assembler.arm" forget-vocab ] with-compilation-unit
