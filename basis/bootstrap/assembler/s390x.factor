! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: assocs bootstrap.image.private compiler.codegen.relocation
compiler.constants compiler.units cpu.architecture cpu.s390x cpu.s390x.assembler
cpu.s390x.assembler.registers generic.single.private kernel
kernel.private layouts literals locals locals.backend make math math.bitwise math.private
namespaces sequences slots.private strings.private threads.private vocabs ;
IN: bootstrap.assembler.s390x

8 \ cell set
big-endian on

ALIAS: ds-0 R2
ALIAS: ds-1 R3
ALIAS: ds-2 R4
ALIAS: ds-3 R5
ALIAS: arg1 R2
ALIAS: arg2 R3
ALIAS: arg3 R4
ALIAS: RETURN R2
ALIAS: PIC-TAIL R5

: address ( reg -- class ) 0 LI64 rc-native-1 ;
: jump ( -- class ) 15 0 BRCL rc-native-0 ;
: call-word ( -- class ) RA 0 BRASL rc-native-0 ;
: save-context ( -- )
    FP CTX context-callstack-top-offset store-cell
    DS CTX context-datastack-offset store-cell
    RS CTX context-retainstack-offset store-cell ;
: load-stacks ( -- )
    DS CTX context-datastack-offset load-cell
    RS CTX context-retainstack-offset load-cell ;
: prolog ( -- )
    SP SP -16 add-offset FP SP 0 store-cell RA SP 8 store-cell FP SP LGR ;
: epilog ( -- )
    FP SP 0 load-cell RA SP 8 load-cell SP SP 16 add-offset ;
: context-epilog ( -- )
    ! The saved PC is a GC marker, not the live continuation's return address.
    ! Preserve the old instruction length for checkpoint template upgrades.
    FP SP 0 load-cell 0 R0 BCR 0 R0 BCR 0 R0 BCR SP SP 16 add-offset ;
: native-call ( name -- ) f R1 address rel-dlsym RA TRAMPOLINE BASR ;
: native-call* ( name -- ) native-call load-stacks ;
: pop-ds ( dst -- ) DS 0 load-cell DS DS -8 add-offset ;
: push-ds ( src -- ) DS DS 8 add-offset DS 0 store-cell ;
: >r ( -- ) ds-0 pop-ds RS RS 8 add-offset ds-0 RS 0 store-cell ;
: r> ( -- ) ds-0 RS 0 load-cell RS RS -8 add-offset ds-0 push-ds ;
! System z branches are six bytes; jit-conditional supplies body length.
: conditional ( test body -- ) [ '[ 6 + @ ] ] dip jit-conditional ; inline
:: repeat-while ( test body -- )
    compiled-offset :> start
    test [ body call 15 start compiled-offset - BRCL ] conditional ; inline
! Signed division and full unsigned multiplication use the even/odd R0:R1 pair.
: signed-divide ( divisor -- ) R0 swap 0xb90d rre ;
: wide-multiply ( multiplier -- ) R0 swap 0xb986 rre ;
: check-divisor ( -- )
    arg2 0 CGHI
    [ 7 swap BRCL ] [ save-context arg1 VM LGR "divide_by_zero" native-call ] conditional ;
: tail-address ( -- ) PIC-TAIL 12 LARL ;
:: mask-bits ( dst src mask -- ) R1 mask LI dst src R1 NGRK ;

[ prolog ] JIT-PROLOG jit-define
[ save-context arg1 VM LGR f native-call* ] JIT-PRIMITIVE jit-define
[ tail-address f jump rel-word-pic-tail ] JIT-WORD-JUMP jit-define
[ f call-word rel-word-pic ] JIT-WORD-CALL jit-define
[
    ds-0 pop-ds ds-0 \ f type-number CGHI
    [ 8 swap BRCL ] [ f jump rel-word ] conditional
    f jump rel-word
] JIT-IF jit-define
[ SAFEPOINT SAFEPOINT 0 store-cell ] JIT-SAFEPOINT jit-define
[ epilog ] JIT-EPILOG jit-define
[ RET ] JIT-RETURN jit-define
[ f ds-0 address rel-literal ds-0 push-ds ] JIT-PUSH-LITERAL jit-define
[ >r f call-word rel-word r> ] JIT-DIP jit-define
[ >r >r f call-word rel-word r> r> ] JIT-2DIP jit-define
[ >r >r >r f call-word rel-word r> r> r> ] JIT-3DIP jit-define
[ R1 pop-ds R1 R1 word-entry-point-offset load-cell 15 R1 BCR ] JIT-EXECUTE jit-define

! Preserve the Linux ABI nonvolatile GPRs and FPRs across reentry.
:: callback-stub ( varargs? -- )
    varargs? [ 512 ] [ 320 ] if :> frame-size
    SP SP frame-size neg add-offset
    ${ R6 R7 R8 R9 R10 R11 R12 R13 R14 }
    [ 8 * 160 + SP swap store-cell ] each-index
    ${ F8 F9 F10 F11 F12 F13 F14 F15 }
    [ 8 * 232 + R0 SP rot STDY ] each-index
    varargs? [
        ! System z va_list points to a 160-byte ABI register-save area.
        ! Capture incoming arguments before the Factor stack registers change.
        ${ R2 R3 R4 R5 R6 }
        [ 8 * 336 + SP swap store-cell ] each-index
        ${ F0 F2 F4 F6 }
        [ 8 * 448 + R0 SP rot STDY ] each-index
        R0 0 LI R0 SP 480 store-cell R0 SP 488 store-cell
        R1 SP 672 add-offset R1 SP 496 store-cell
        R1 SP 320 add-offset R1 SP 504 store-cell
    ] when
    0 VM address rel-vm
    CTX VM vm-context-offset load-cell CTX SP 296 store-cell
    SAFEPOINT address rel-safepoint
    TRAMPOLINE address rel-trampoline
    TRAMPOLINE2 address rel-trampoline2
    R1 address rel-inline-cache-miss
    R1 address rel-megamorphic-cache-hits
    CTX VM vm-spare-context-offset load-cell CTX VM vm-context-offset store-cell
    SP CTX context-callstack-save-offset store-cell
    SP CTX context-callstack-bottom-offset load-cell SP SP 16 add-offset
    FP 0 LI load-stacks
    f R1 address rel-word RA R1 BASR
    SP CTX context-callstack-save-offset load-cell
    CTX SP 296 load-cell CTX VM vm-context-offset store-cell
    ${ F8 F9 F10 F11 F12 F13 F14 F15 }
    [ 8 * 232 + R0 SP rot LDY ] each-index
    ${ R6 R7 R8 R9 R10 R11 R12 R13 R14 }
    [ 8 * 160 + SP swap load-cell ] each-index
    SP SP frame-size add-offset RET ;
[ f callback-stub ] CALLBACK-STUB jit-define
[ t callback-stub ] make-jit-no-params
CALLBACK-STUB special-objects get at swap suffix
CALLBACK-STUB special-objects get set-at

[ f R1 address rel-untagged R2 R1 DS 0 LG ] PIC-LOAD jit-define
[ R3 R2 tag-mask get mask-bits R4 R3 LGR ] PIC-TAG jit-define
[
    R3 R2 tag-mask get mask-bits R3 tuple type-number CGHI
    [ 7 swap BRCL ] [ R3 R2 tuple-class-offset load-cell ] conditional
] PIC-TUPLE jit-define
[ f R1 address rel-untagged R3 R1 CGR ] PIC-CHECK-TAG jit-define
[ f R1 address rel-literal R3 R1 CGR ] PIC-CHECK-TUPLE jit-define
[ [ 7 swap BRCL ] [ f jump rel-word ] conditional ] PIC-HIT jit-define
[ PIC-TAIL RA LGR f jump rel-word ] PIC-MISS-JUMP jit-define
[ f jump rel-word ] PIC-MISS-TAIL-JUMP jit-define

[
    R3 R2 tag-mask get mask-bits R3 R3 R0 tag-bits get SLLG
    R3 tuple type-number tag-fixnum CGHI
    [ 7 swap BRCL ] [ R3 R2 tuple-class-offset load-cell ] conditional
    f R4 address rel-literal
    R0 R3 mega-cache-size get 1 - bootstrap-cells mask-bits
    R4 R4 R0 AGRK R1 R4 array-start-offset load-cell R3 R1 CGR
    [ 7 swap BRCL ] [
        R1 address rel-megamorphic-cache-hits
        R0 R1 0 load-cell R0 1 AGHI R0 R1 0 store-cell
        R1 R4 array-start-offset bootstrap-cell + load-cell
        R1 R1 word-entry-point-offset load-cell 15 R1 BCR
    ] conditional
] MEGA-LOOKUP jit-define

[ save-context arg1 FP 8 load-cell arg2 VM LGR "inline_cache_miss" native-call* ]
[ RA RETURN BASR ] [ 15 RETURN BCR ] \ inline-cache-miss define-combinator-primitive
[ save-context arg1 PIC-TAIL LGR arg2 VM LGR "inline_cache_miss" native-call* ]
[ RA RETURN BASR ] [ 15 RETURN BCR ] \ inline-cache-miss-tail define-combinator-primitive

[ R2 pop-ds R1 R2 quot-entry-point-offset load-cell ]
[ RA R1 BASR ] [ 15 R1 BCR ] \ (call) define-combinator-primitive
[ R1 pop-ds R1 R1 word-entry-point-offset load-cell ]
[ RA R1 BASR ] [ 15 R1 BCR ] \ (execute) define-combinator-primitive
[ save-context arg2 VM LGR "lazy_jit_compile" native-call*
  R1 RETURN quot-entry-point-offset load-cell ]
[ RA R1 BASR ] [ 15 R1 BCR ] \ lazy-jit-compile define-combinator-primitive

! EFPC/SFPC transfer the complete floating-point control state.
: read-fpc ( reg -- ) R 4 shift 0xb38c0000 bitor emit-4 ;
: write-fpc ( reg -- ) R 4 shift 0xb3840000 bitor emit-4 ;
:: compare-values ( mask -- )
    ds-0 pop-ds ds-1 DS 0 load-cell ds-1 ds-0 CGR
    R4 \ f type-number LI
    [ mask 15 bitxor swap BRCL ] [ t R4 address rel-literal ] conditional
    R4 DS 0 store-cell ;
: signal-save ( -- )
    SP SP -448 add-offset
    15 <iota> [ [ int-register boa ] [ 8 * 160 + ] bi [ R0 SP ] dip STG ] each
    16 <iota> [ [ fp-register boa ] [ 8 * 288 + ] bi [ R0 SP ] dip STDY ] each
    R0 read-fpc R0 SP 416 store-cell
    save-context R1 VM vm-signal-handler-addr-offset load-cell RA TRAMPOLINE BASR
    R0 SP 416 load-cell R0 write-fpc
    16 <iota> [ [ fp-register boa ] [ 8 * 288 + ] bi [ R0 SP ] dip LDY ] each
    15 <iota> [ [ int-register boa ] [ 8 * 160 + ] bi [ R0 SP ] dip LG ] each
    SP SP 448 add-offset ;

{
    { inline-cache-miss-resume [
        prolog save-context arg1 PIC-TAIL LGR arg2 VM LGR
        "inline_cache_miss" native-call* epilog 15 RETURN BCR
    ] }
    { fpu-state [ RETURN read-fpc R0 0 LI R0 write-fpc ] }
    { set-fpu-state [ arg1 write-fpc ] }
    { leaf-signal-handler [
        FP SP 16 store-cell RA SP 24 store-cell
        R1 SP 16 add-offset R1 SP 0 store-cell FP SP LGR
        signal-save
        R1 SP 8 load-cell FP SP 16 load-cell RA SP 24 load-cell SP SP 32 add-offset 15 R1 BCR
    ] }
    { signal-handler [
        FP SP 0 store-cell FP SP LGR signal-save
        FP SP 0 load-cell R1 SP 8 load-cell SP SP 16 add-offset 15 R1 BCR
    ] }
    { c-to-factor [
        arg2 arg1 LGR arg1 VM LGR "begin_callback" native-call
        R1 RETURN quot-entry-point-offset load-cell RA R1 BASR
        arg1 VM LGR "end_callback" native-call
    ] }
    { unwind-native-frames [
        SP arg2 LGR epilog 0 VM address rel-vm
        CTX VM vm-context-offset load-cell load-stacks
        SAFEPOINT address rel-safepoint TRAMPOLINE address rel-trampoline
        TRAMPOLINE2 address rel-trampoline2
        R0 0 LI R0 VM vm-fault-flag-offset store-cell
        R1 arg1 quot-entry-point-offset load-cell 15 R1 BCR
    ] }
    { set-callstack [
        ds-0 pop-ds R3 CTX context-callstack-bottom-offset load-cell
        R4 ds-0 callstack-top-offset add-offset R5 ds-0 callstack-length-offset load-cell
        R5 R5 R0 tag-bits get SRAG R2 R3 R5 SGRK SP R2 LGR
        [ R2 R3 CLGR 10 swap BRCL ] [
            R0 R4 0 load-cell R1 R4 8 load-cell FP R2 R0 AGRK
            FP R2 0 store-cell R1 R2 8 store-cell R4 R4 16 add-offset R2 R2 16 add-offset
            [ R2 FP CLGR 10 swap BRCL ] [
                R0 R4 0 load-cell R0 R2 0 store-cell R4 R4 8 add-offset R2 R2 8 add-offset
            ] repeat-while
        ] repeat-while
        epilog RET
    ] }
    { (set-context) [
        ds-0 pop-ds ds-0 ds-0 alien-offset load-cell ds-1 pop-ds
        R1 0 LARL prolog R1 SP 8 store-cell save-context
        CTX ds-0 LGR CTX VM vm-context-offset store-cell
        SP CTX context-callstack-top-offset load-cell
        context-epilog
        load-stacks ds-1 push-ds
    ] }
    { (set-context-and-delete) [
        arg1 VM LGR "delete_context" native-call
        ds-0 pop-ds ds-0 ds-0 alien-offset load-cell ds-1 pop-ds
        CTX ds-0 LGR CTX VM vm-context-offset store-cell
        SP CTX context-callstack-top-offset load-cell
        context-epilog
        load-stacks ds-1 push-ds
    ] }
    { (start-context) [
        save-context arg1 VM LGR "new_context" native-call*
        R4 RETURN LGR ds-0 pop-ds ds-1 pop-ds R1 0 LARL
        prolog R1 SP 8 store-cell save-context
        CTX R4 LGR CTX VM vm-context-offset store-cell
        FP CTX context-callstack-top-offset load-cell SP FP LGR load-stacks
        ds-1 push-ds arg1 ds-0 LGR R1 arg1 quot-entry-point-offset load-cell 15 R1 BCR
    ] }
    { (start-context-and-delete) [
        save-context arg1 VM LGR "reset_context" native-call*
        FP CTX context-callstack-top-offset load-cell SP FP LGR load-stacks
        arg1 pop-ds R1 arg1 quot-entry-point-offset load-cell 15 R1 BCR
    ] }
    { drop [ DS DS -8 add-offset ] }
    { 2drop [ DS DS -16 add-offset ] }
    { 3drop [ DS DS -24 add-offset ] }
    { 4drop [ DS DS -32 add-offset ] }
    { dup [ ds-0 DS 0 load-cell ds-0 push-ds ] }
    { over [ ds-0 DS -8 load-cell ds-0 push-ds ] }
    { pick [ ds-0 DS -16 load-cell ds-0 push-ds ] }
    { swap [ ds-0 DS 0 load-cell ds-1 DS -8 load-cell ds-0 DS -8 store-cell ds-1 DS 0 store-cell ] }
    { nip [ ds-0 pop-ds ds-0 DS 0 store-cell ] }
    { 2nip [ ds-0 pop-ds DS DS -8 add-offset ds-0 DS 0 store-cell ] }
    { swapd [ ds-0 DS 0 load-cell ds-1 DS -8 load-cell ds-2 DS -16 load-cell ds-1 DS -16 store-cell ds-2 DS -8 store-cell ds-0 DS 0 store-cell ] }
    { 2dup [ ds-0 DS 0 load-cell ds-1 DS -8 load-cell DS DS 16 add-offset ds-1 DS -24 store-cell ds-0 DS -16 store-cell ds-1 DS -8 store-cell ds-0 DS 0 store-cell ] }
    { dupd [ ds-0 DS 0 load-cell ds-1 DS -8 load-cell DS DS 8 add-offset ds-1 DS -16 store-cell ds-1 DS -8 store-cell ds-0 DS 0 store-cell ] }
    { 3dup [ ds-0 DS 0 load-cell ds-1 DS -8 load-cell ds-2 DS -16 load-cell DS DS 24 add-offset ds-2 DS -40 store-cell ds-1 DS -32 store-cell ds-0 DS -24 store-cell ds-2 DS -16 store-cell ds-1 DS -8 store-cell ds-0 DS 0 store-cell ] }
    { 4dup [ ds-0 DS 0 load-cell ds-1 DS -8 load-cell ds-2 DS -16 load-cell ds-3 DS -24 load-cell DS DS 32 add-offset ds-3 DS -56 store-cell ds-2 DS -48 store-cell ds-1 DS -40 store-cell ds-0 DS -32 store-cell ds-3 DS -24 store-cell ds-2 DS -16 store-cell ds-1 DS -8 store-cell ds-0 DS 0 store-cell ] }
    { rot [ ds-0 DS 0 load-cell ds-1 DS -8 load-cell ds-2 DS -16 load-cell ds-1 DS -16 store-cell ds-0 DS -8 store-cell ds-2 DS 0 store-cell ] }
    { -rot [ ds-0 DS 0 load-cell ds-1 DS -8 load-cell ds-2 DS -16 load-cell ds-0 DS -16 store-cell ds-2 DS -8 store-cell ds-1 DS 0 store-cell ] }
    { eq? [ 8 compare-values ] }
    { fixnum< [ 4 compare-values ] }
    { fixnum<= [ 12 compare-values ] }
    { fixnum> [ 2 compare-values ] }
    { fixnum>= [ 10 compare-values ] }
    { tag [ ds-0 DS 0 load-cell ds-0 ds-0 tag-mask get mask-bits
        ds-0 ds-0 R0 tag-bits get SLLG ds-0 DS 0 store-cell ] }
    { drop-locals [ ds-0 pop-ds ds-0 ds-0 R0 tag-bits get 3 - SRAG RS RS ds-0 SGRK ] }
    { get-local [ ds-0 DS 0 load-cell ds-0 ds-0 R0 tag-bits get 3 - SRAG
        R1 RS ds-0 AGRK ds-0 R1 0 load-cell ds-0 DS 0 store-cell ] }
    { both-fixnums? [
        ds-0 pop-ds ds-1 DS 0 load-cell ds-0 ds-0 ds-1 OGRK
        ds-0 ds-0 tag-mask get mask-bits ds-0 0 CGHI
        [ 8 swap BRCL ] [ \ f type-number ds-0 swap LI ds-0 DS 0 store-cell ] conditional
        [ 7 swap BRCL ] [ ds-0 1 tag-fixnum LI ds-0 DS 0 store-cell ] conditional
    ] }
    { fixnum-bitnot [ ds-0 DS 0 load-cell R1 tag-mask get bitnot LI
        ds-0 ds-0 R1 XGRK ds-0 DS 0 store-cell ] }
    { fixnum*fast [ ds-0 pop-ds ds-1 DS 0 load-cell ds-0 ds-0 R0 tag-bits get SRAG
        ds-0 ds-1 MSGR ds-0 DS 0 store-cell ] }
    { slot [
        ds-0 pop-ds ds-1 DS 0 load-cell ds-0 ds-0 R0 tag-bits get 3 - SRAG
        ds-1 ds-1 tag-mask get bitnot mask-bits
        R1 ds-1 ds-0 AGRK ds-0 R1 0 load-cell ds-0 DS 0 store-cell
    ] }
    { string-nth-fast [
        ds-0 pop-ds ds-1 DS 0 load-cell ds-1 ds-1 R0 tag-bits get SRAG
        R1 ds-0 ds-1 AGRK ds-0 R0 R1 string-offset LLGC
        ds-0 ds-0 R0 tag-bits get SLLG ds-0 DS 0 store-cell
    ] }
    { load-local [ >r ] }
    { fixnum-mod [
        arg2 pop-ds R1 DS 0 load-cell check-divisor
        arg2 signed-divide R0 DS 0 store-cell
    ] }
    { fixnum/i-fast [
        arg2 pop-ds R1 DS 0 load-cell check-divisor
        arg2 signed-divide R1 R1 R0 tag-bits get SLLG R1 DS 0 store-cell
    ] }
    { fixnum/mod-fast [
        arg2 DS 0 load-cell R1 DS -8 load-cell check-divisor
        arg2 signed-divide R1 R1 R0 tag-bits get SLLG R1 DS -8 store-cell R0 DS 0 store-cell
    ] }
    { fixnum-shift-fast [
        ds-0 pop-ds ds-1 DS 0 load-cell ds-0 ds-0 R0 tag-bits get SRAG ds-0 0 CGHI
        [ 4 swap BRCL ] [ ds-1 ds-1 ds-0 0 SLLG 15 24 BRCL ] conditional
        [
            ds-0 ds-0 LCGR ds-1 ds-1 ds-0 0 SRAG
            ds-1 ds-1 tag-mask get bitnot mask-bits
        ] call ds-1 DS 0 store-cell
    ] }
    { fixnum* [
        arg2 pop-ds arg1 DS 0 load-cell save-context
        arg1 arg1 R0 tag-bits get SRAG R1 arg1 LGR arg2 wide-multiply
        R1 DS 0 store-cell
        R4 arg1 R0 63 SRAG R4 R4 arg2 NGRK R0 R0 R4 SGRK
        R4 arg2 R0 63 SRAG R4 R4 arg1 NGRK R0 R0 R4 SGRK
        R4 R1 R0 63 SRAG R0 R4 CGR
        [ 8 swap BRCL ] [
            arg2 arg2 R0 tag-bits get SRAG arg3 VM LGR "overflow_fixnum_multiply" native-call*
        ] conditional
    ] }
    { fixnum+ [
        arg2 pop-ds arg1 DS 0 load-cell save-context
        R0 arg1 arg2 AGRK R0 DS 0 store-cell
        [ 14 swap BRCL ] [ arg3 VM LGR "overflow_fixnum_add" native-call* ] conditional
    ] }
    { fixnum- [
        arg2 pop-ds arg1 DS 0 load-cell save-context
        R0 arg1 arg2 SGRK R0 DS 0 store-cell
        [ 14 swap BRCL ] [ arg3 VM LGR "overflow_fixnum_subtract" native-call* ] conditional
    ] }
    { fixnum+fast [ ds-0 pop-ds ds-1 DS 0 load-cell ds-0 ds-1 ds-0 AGRK ds-0 DS 0 store-cell ] }
    { fixnum-fast [ ds-0 pop-ds ds-1 DS 0 load-cell ds-0 ds-1 ds-0 SGRK ds-0 DS 0 store-cell ] }
    { fixnum-bitand [ ds-0 pop-ds ds-1 DS 0 load-cell ds-0 ds-1 ds-0 NGRK ds-0 DS 0 store-cell ] }
    { fixnum-bitor [ ds-0 pop-ds ds-1 DS 0 load-cell ds-0 ds-1 ds-0 OGRK ds-0 DS 0 store-cell ] }
    { fixnum-bitxor [ ds-0 pop-ds ds-1 DS 0 load-cell ds-0 ds-1 ds-0 XGRK ds-0 DS 0 store-cell ] }
} define-sub-primitives

[ "bootstrap.assembler.s390x" forget-vocab ] with-compilation-unit
