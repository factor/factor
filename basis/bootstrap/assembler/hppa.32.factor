! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: assocs bootstrap.image.private compiler.codegen.relocation
compiler.constants compiler.units cpu.hppa.assembler
cpu.hppa.assembler.registers generic.single.private kernel
kernel.private layouts literals locals locals.backend make math math.bitwise
math.private namespaces sequences slots.private strings.private
threads.private vocabs ;
FROM: cpu.hppa.assembler.registers => cache ;
IN: bootstrap.assembler.hppa

4 \ cell set
: ADDI ( rd rs imm -- ) LDO ;
: MV ( rd rs -- ) COPY ;
: SW ( rs base offset -- ) STW ;
: LW ( rd base offset -- ) LDW ;
: LBU ( rd base offset -- ) LDB ;
: load-address ( rd -- class ) 0 LI rc-native-0 ;
: call-word ( word -- ) IP0 load-address rel-word IP0 CALL ;
: call-pic-word ( word -- ) IP0 load-address rel-word-pic IP0 CALL ;
: jump-word ( word -- ) IP0 load-address rel-word IP0 JUMP ;
: jump-tail-word ( word -- ) IP0 load-address rel-word-pic-tail IP0 JUMP ;
: JR ( rs -- ) JUMP ;
: BEQ ( lhs rhs disp -- ) cpu.hppa.assembler:BEQ NOP ;
: BNE ( lhs rhs disp -- ) cpu.hppa.assembler:BNE NOP ;
: BLT ( lhs rhs disp -- ) cpu.hppa.assembler:BLT NOP ;
: BGE ( lhs rhs disp -- ) cpu.hppa.assembler:BGE NOP ;
: BLTU ( lhs rhs disp -- ) cpu.hppa.assembler:BLTU NOP ;
: BGEU ( lhs rhs disp -- ) cpu.hppa.assembler:BGEU NOP ;
: jit-conditional* ( test-quot false-quot -- )
    [ '[ 8 + @ ] ] dip jit-conditional ; inline
:: ANDI ( rd rs value -- ) AT value LI rd rs AT AND ;
:: XORI ( rd rs value -- ) AT value LI rd rs AT XOR ;
:: NEG ( rd rs -- ) rd ZERO rs SUB ;
:: SLL ( rd rs count -- )
    AT 31 LI AT AT count SUB AT MTSAR rd rs 32 ZVDEP ;
:: SRA ( rd rs count -- )
    AT 31 LI AT AT count SUB AT MTSAR rd rs 32 VEXTRS ;
:: dstore ( reg base offset -- ) AT base offset LDO reg AT 0 FSTD ;
:: dload ( reg base offset -- ) AT base offset LDO reg AT 0 FLDD ;
:: MUL ( rd lhs rhs -- )
    lhs NATIVE-SP -16 SW fp-temp NATIVE-SP -16 FLDW
    rhs NATIVE-SP -16 SW fp-temp2 NATIVE-SP -16 FLDW
    fp-temp fp-temp fp-temp2 XMPYU fp-temp NATIVE-SP -16 FSTD
    rd NATIVE-SP -12 LW ;
:: MULH ( rd lhs rhs -- )
    lhs NATIVE-SP -16 SW fp-temp NATIVE-SP -16 FLDW
    rhs NATIVE-SP -16 SW fp-temp2 NATIVE-SP -16 FLDW
    fp-temp fp-temp fp-temp2 XMPYU fp-temp NATIVE-SP -16 FSTD
    AT lhs 31 SRAI AT AT rhs AND
    temp2 rhs 31 SRAI temp2 temp2 lhs AND
    rd NATIVE-SP -16 LW rd rd AT SUB rd rd temp2 SUB ;
:: here-address ( rd -- )
    rd load-address compiled-offset 8 - neg swap rel-here ;

: save-context ( -- )
    FP CTX context-callstack-top-offset SW
    DS CTX context-datastack-offset SW
    RS CTX context-retainstack-offset SW ;
: load-stacks ( -- )
    DS CTX context-datastack-offset LW
    RS CTX context-retainstack-offset LW ;
: prolog ( -- )
    AT FP MV FP FP -16 ADDI AT FP 0 SW RA FP 4 SW ;
: epilog ( -- )
    RA FP 4 LW FP FP 0 LW ;
: native-call ( name -- )
    f IP0 load-address rel-dlsym TRAMPOLINE CALL ;
 : native-call* ( name -- ) native-call load-stacks ;
:: native-divide ( rd lhs rhs symbol -- )
    AT FP MV FP FP -64 ADDI AT FP 0 SW RA FP 4 SW
    GP FP 8 SW R31 FP 12 SW
    10 <iota> [ dup 20 + int-register boa FP rot 4 * 16 + SW ] each
    AT lhs MV IP1 rhs MV arg1 AT MV arg2 IP1 MV
    symbol native-call RETURN FP 60 SW
    10 <iota> [ dup 20 + int-register boa FP rot 4 * 16 + LW ] each
    GP FP 8 LW R31 FP 12 LW RA FP 4 LW rd FP 60 LW
    FP FP 0 LW ;
: DIV ( rd lhs rhs -- ) "hppa_divide_i32" native-divide ;
: REM ( rd lhs rhs -- ) "hppa_remainder_i32" native-divide ;
: pop-ds ( rd -- ) DS 0 LW DS DS -4 ADDI ;
: push-ds ( rs -- ) DS DS 4 ADDI DS 0 SW ;
: >r ( -- ) ds-0 pop-ds RS RS 4 ADDI ds-0 RS 0 SW ;
: r> ( -- ) ds-0 RS 0 LW RS RS -4 ADDI ds-0 push-ds ;
: tail-address ( -- )
    temp RA MV RA 8 BL NOP
    ! The 36-byte tail sequence ends 24 bytes after BL PC+8; strip privilege 3.
    PIC-TAIL RA 21 ADDI RA temp MV ;
: check-divisor ( -- )
    [ ds-0 ZERO rot BNE ] [
        save-context arg1 VM MV "divide_by_zero" native-call
    ] jit-conditional* ;

[ prolog ] JIT-PROLOG jit-define
[ save-context arg1 VM MV f native-call* ] JIT-PRIMITIVE jit-define
[ tail-address f jump-tail-word ] JIT-WORD-JUMP jit-define
[ f call-pic-word ] JIT-WORD-CALL jit-define
[
    ds-0 pop-ds temp \ f type-number LI
    [ ds-0 temp rot BEQ ] [ f jump-word ] jit-conditional*
    f jump-word
] JIT-IF jit-define
[ SAFEPOINT SAFEPOINT 0 SW ] JIT-SAFEPOINT jit-define
[ epilog ] JIT-EPILOG jit-define
[ RET ] JIT-RETURN jit-define
[ f ds-0 load-address rel-literal ds-0 push-ds ] JIT-PUSH-LITERAL jit-define
[ >r f call-word r> ] JIT-DIP jit-define
[ >r >r f call-word r> r> ] JIT-2DIP jit-define
[ >r >r >r f call-word r> r> r> ] JIT-3DIP jit-define
[ temp pop-ds temp temp word-entry-point-offset LW temp JR ] JIT-EXECUTE jit-define

! The native frame stays on r30 while Factor frames use r18.
: jit-callback-stub ( varargs? -- )
    drop NATIVE-SP NATIVE-SP 256 ADDI
    16 <iota> [ dup 3 + int-register boa NATIVE-SP rot 4 * 240 - SW ] each
    10 <iota> [ dup 12 + fp-register boa NATIVE-SP rot 8 * 176 - dstore ] each
    GP NATIVE-SP -96 SW RA NATIVE-SP -92 SW
    ${ arg1 arg2 arg3 arg4 } [ 4 * 84 - NATIVE-SP swap SW ] each-index
    ! GNU va_start traverses the caller-reserved descending argument homes.
    ${ arg1 arg2 arg3 arg4 } [ 4 * neg 292 - NATIVE-SP swap SW ] each-index
    ${ F4 F5 F6 F7 } [ 8 * 64 - NATIVE-SP swap dstore ] each-index
    0 VM load-address rel-vm
    CTX VM vm-context-offset LW CTX NATIVE-SP -88 SW
    SAFEPOINT load-address rel-safepoint
    TRAMPOLINE load-address rel-trampoline
    TRAMPOLINE2 load-address rel-trampoline2
    CACHE-MISS load-address rel-inline-cache-miss
    MEGA-HITS load-address rel-megamorphic-cache-hits
    CTX VM vm-spare-context-offset LW CTX VM vm-context-offset SW
    NATIVE-SP CTX context-callstack-save-offset SW
    FP CTX context-callstack-bottom-offset LW load-stacks
    f IP0 load-address rel-word IP0 CALL
    NATIVE-SP CTX context-callstack-save-offset LW
    CTX NATIVE-SP -88 LW CTX VM vm-context-offset SW
    GP NATIVE-SP -96 LW RA NATIVE-SP -92 LW
    10 <iota> [ dup 12 + fp-register boa NATIVE-SP rot 8 * 176 - dload ] each
    16 <iota> [ dup 3 + int-register boa NATIVE-SP rot 4 * 240 - LW ] each
    NATIVE-SP NATIVE-SP -256 ADDI RET ;
[ f jit-callback-stub ] CALLBACK-STUB jit-define
[ t jit-callback-stub ] make-jit-no-params
CALLBACK-STUB special-objects get at swap suffix
CALLBACK-STUB special-objects get set-at

[ obj DS 0 LW f rc-native-1 rel-untagged ] PIC-LOAD jit-define
[ type obj tag-mask get ANDI temp2 type MV ] PIC-TAG jit-define
[
    type obj tag-mask get ANDI temp tuple type-number LI
    [ type temp rot BNE ] [ type obj tuple-class-offset LW ] jit-conditional*
] PIC-TUPLE jit-define
[ f temp load-address rel-untagged temp2 type temp XOR ] PIC-CHECK-TAG jit-define
[ f temp load-address rel-literal temp2 type temp XOR ] PIC-CHECK-TUPLE jit-define
[ [ temp2 ZERO rot BNE ] [ f jump-word ] jit-conditional* ] PIC-HIT jit-define
[ PIC-TAIL RA MV f jump-word ] PIC-MISS-JUMP jit-define
[ f jump-word ] PIC-MISS-TAIL-JUMP jit-define
[
    type obj tag-mask get ANDI type type tag-bits get SLLI
    temp tuple type-number tag-fixnum LI
    [ type temp rot BNE ] [ type obj tuple-class-offset LW ] jit-conditional*
    f cache load-address rel-literal
    temp type 1 SRLI
    temp temp mega-cache-size get 1 - bootstrap-cells ANDI
    cache cache temp ADD temp cache array-start-offset LW
    [ type temp rot BNE ] [
        MEGA-HITS load-address rel-megamorphic-cache-hits
        temp MEGA-HITS 0 LW temp temp 1 ADDI temp MEGA-HITS 0 SW
        temp cache array-start-offset bootstrap-cell + LW
        temp temp word-entry-point-offset LW temp JR
    ] jit-conditional*
] MEGA-LOOKUP jit-define

[ arg1 pop-ds temp arg1 quot-entry-point-offset LW ]
[ temp CALL ] [ temp JR ] \ (call) define-combinator-primitive
[ temp pop-ds temp temp word-entry-point-offset LW ]
[ temp CALL ] [ temp JR ] \ (execute) define-combinator-primitive
[ save-context arg2 VM MV "lazy_jit_compile" native-call* arg1 RETURN MV
  temp RETURN quot-entry-point-offset LW ]
[ temp CALL ] [ temp JR ] \ lazy-jit-compile define-combinator-primitive
[ save-context arg1 FP 4 LW arg2 VM MV IP0 CACHE-MISS MV
  TRAMPOLINE CALL load-stacks ]
[ RETURN CALL ] [ RETURN JR ] \ inline-cache-miss define-combinator-primitive
[ save-context arg1 PIC-TAIL MV arg2 VM MV IP0 CACHE-MISS MV
  TRAMPOLINE CALL load-stacks ]
[ RETURN CALL ] [ RETURN JR ] \ inline-cache-miss-tail define-combinator-primitive

! Preserve all integer and floating state; native r30 stays separate.
: jit-signal-handler ( -- )
    FP FP -416 ADDI AT FP 20 SW
    ! This header names handler code; interrupted RA belongs to the leaf caller.
    AT FP 416 ADDI AT FP 0 SW AT here-address AT FP 4 SW
    32 <iota> [ dup 18 = over 1 = or [ drop ] [ dup int-register boa FP rot 4 * 16 + SW ] if ] each
    32 <iota> [ dup fp-register boa FP rot 8 * 144 + dstore ] each
    AT MFSAR AT FP 8 SW
    save-context IP0 VM vm-signal-handler-addr-offset LW TRAMPOLINE CALL
    AT FP 8 LW AT MTSAR
    32 <iota> reverse [ dup fp-register boa FP rot 8 * 144 + dload ] each
    32 <iota> reverse [ dup 18 = over 1 = or [ drop ] [ dup int-register boa FP rot 4 * 16 + LW ] if ] each
    FP FP 0 LW ;
:: back-to ( destination -- )
    ZERO ZERO destination compiled-offset - BEQ ;
:: copy-linked-callstack ( -- )
    compiled-offset :> outer
    [ top bottom rot BGEU ] [
        temp1 src 0 LW temp2 src 4 LW IP1 top temp1 ADD
        IP1 top 0 SW temp2 top 4 SW src src 8 ADDI top top 8 ADDI
        compiled-offset :> inner
        [ top IP1 rot BGEU ] [
            temp1 src 0 LW temp1 top 0 SW
            src src 4 ADDI top top 4 ADDI inner back-to
        ] jit-conditional*
        outer back-to
    ] jit-conditional* ;
:: jit-compare ( branch -- )
    ds-0 DS 0 LW ds-1 DS -4 LW DS DS -4 ADDI
    t temp load-address rel-literal
    temp1 \ f type-number LI
    ds-1 ds-0 12 branch call
    temp1 temp MV temp1 DS 0 SW ; inline

{
    { c-to-factor [
        arg2 arg1 MV arg1 VM MV "begin_callback" native-call arg1 RETURN MV
        temp RETURN quot-entry-point-offset LW temp CALL
        arg1 VM MV "end_callback" native-call
    ] }
    { unwind-native-frames [
        NATIVE-SP arg2 MV 0 VM load-address rel-vm
        CTX VM vm-context-offset LW FP CTX context-callstack-top-offset LW epilog load-stacks
        SAFEPOINT load-address rel-safepoint
        TRAMPOLINE load-address rel-trampoline
        TRAMPOLINE2 load-address rel-trampoline2
        CACHE-MISS load-address rel-inline-cache-miss
        MEGA-HITS load-address rel-megamorphic-cache-hits
        ZERO VM vm-fault-flag-offset SW
        temp arg1 quot-entry-point-offset LW temp JR
    ] }
    { inline-cache-miss-resume [
        prolog save-context arg1 PIC-TAIL MV arg2 VM MV IP0 CACHE-MISS MV
        TRAMPOLINE CALL load-stacks epilog RETURN JR
    ] }
    { fpu-state [ F0 NATIVE-SP -16 FSTD RETURN NATIVE-SP -16 LW
        ZERO NATIVE-SP -16 SW ZERO NATIVE-SP -12 SW F0 NATIVE-SP -16 FLDD ] }
    { set-fpu-state [ arg1 NATIVE-SP -16 SW ZERO NATIVE-SP -12 SW
        F0 NATIVE-SP -16 FLDD ] }
    { leaf-signal-handler [ RA FP 20 SW jit-signal-handler AT FP 4 LW FP FP 16 LW AT BV AT FP -428 LW ] }
    { signal-handler [ jit-signal-handler AT FP 4 LW FP FP 0 LW AT BV AT FP -412 LW ] }
    { drop [ DS DS -4 ADDI ] }
    { 2drop [ DS DS -8 ADDI ] }
    { 3drop [ DS DS -12 ADDI ] }
    { 4drop [ DS DS -16 ADDI ] }
    { dup [ ds-0 DS 0 LW DS DS 4 ADDI ds-0 DS -4 SW ds-0 DS 0 SW ] }
    { over [ ds-0 DS 0 LW ds-1 DS -4 LW DS DS 4 ADDI ds-1 DS -8 SW ds-0 DS -4 SW ds-1 DS 0 SW ] }
    { pick [ ds-0 DS 0 LW ds-1 DS -4 LW ds-2 DS -8 LW DS DS 4 ADDI ds-2 DS -12 SW ds-1 DS -8 SW ds-0 DS -4 SW ds-2 DS 0 SW ] }
    { swap [ ds-0 DS 0 LW ds-1 DS -4 LW ds-0 DS -4 SW ds-1 DS 0 SW ] }
    { swapd [ ds-0 DS 0 LW ds-1 DS -4 LW ds-2 DS -8 LW ds-1 DS -8 SW ds-2 DS -4 SW ds-0 DS 0 SW ] }
    { nip [ ds-0 DS 0 LW ds-1 DS -4 LW DS DS -4 ADDI ds-0 DS 0 SW ] }
    { 2nip [ ds-0 DS 0 LW ds-1 DS -4 LW ds-2 DS -8 LW DS DS -8 ADDI ds-0 DS 0 SW ] }
    { 2dup [ ds-0 DS 0 LW ds-1 DS -4 LW DS DS 8 ADDI ds-1 DS -12 SW ds-0 DS -8 SW ds-1 DS -4 SW ds-0 DS 0 SW ] }
    { dupd [ ds-0 DS 0 LW ds-1 DS -4 LW DS DS 4 ADDI ds-1 DS -8 SW ds-1 DS -4 SW ds-0 DS 0 SW ] }
    { 3dup [ ds-0 DS 0 LW ds-1 DS -4 LW ds-2 DS -8 LW DS DS 12 ADDI ds-2 DS -20 SW ds-1 DS -16 SW ds-0 DS -12 SW ds-2 DS -8 SW ds-1 DS -4 SW ds-0 DS 0 SW ] }
    { 4dup [ ds-0 DS 0 LW ds-1 DS -4 LW ds-2 DS -8 LW ds-3 DS -12 LW DS DS 16 ADDI ds-3 DS -28 SW ds-2 DS -24 SW ds-1 DS -20 SW ds-0 DS -16 SW ds-3 DS -12 SW ds-2 DS -8 SW ds-1 DS -4 SW ds-0 DS 0 SW ] }
    { rot [ ds-0 DS 0 LW ds-1 DS -4 LW ds-2 DS -8 LW ds-1 DS -8 SW ds-0 DS -4 SW ds-2 DS 0 SW ] }
    { -rot [ ds-0 DS 0 LW ds-1 DS -4 LW ds-2 DS -8 LW ds-0 DS -8 SW ds-2 DS -4 SW ds-1 DS 0 SW ] }
    { eq? [ [ BNE ] jit-compare ] }
    { fixnum< [ [ BGE ] jit-compare ] }
    { fixnum<= [ [ swapd BLT ] jit-compare ] }
    { fixnum> [ [ swapd BGE ] jit-compare ] }
    { fixnum>= [ [ BLT ] jit-compare ] }
    { tag [ ds-0 DS 0 LW ds-0 ds-0 tag-mask get ANDI
        ds-0 ds-0 tag-bits get SLLI ds-0 DS 0 SW ] }
    { drop-locals [ ds-0 pop-ds ds-0 ds-0 tag-bits get 2 - SRAI RS RS ds-0 SUB ] }
    { get-local [ ds-0 DS 0 LW ds-0 ds-0 tag-bits get 2 - SRAI
        temp RS ds-0 ADD ds-0 temp 0 LW ds-0 DS 0 SW ] }
    { load-local [ >r ] }
    { both-fixnums? [
        ds-0 DS 0 LW ds-1 DS -4 LW DS DS -4 ADDI
        ds-0 ds-0 ds-1 OR ds-0 ds-0 tag-mask get ANDI
        temp 1 tag-fixnum LI temp1 \ f type-number LI
        ds-0 ZERO 12 BNE temp1 temp MV temp1 DS 0 SW
    ] }
    { fixnum+fast [ ds-0 DS 0 LW ds-1 DS -4 LW DS DS -4 ADDI ds-0 ds-1 ds-0 ADD ds-0 DS 0 SW ] }
    { fixnum-fast [ ds-0 DS 0 LW ds-1 DS -4 LW DS DS -4 ADDI ds-0 ds-1 ds-0 SUB ds-0 DS 0 SW ] }
    { fixnum-bitand [ ds-0 DS 0 LW ds-1 DS -4 LW DS DS -4 ADDI ds-0 ds-1 ds-0 AND ds-0 DS 0 SW ] }
    { fixnum-bitor [ ds-0 DS 0 LW ds-1 DS -4 LW DS DS -4 ADDI ds-0 ds-1 ds-0 OR ds-0 DS 0 SW ] }
    { fixnum-bitxor [ ds-0 DS 0 LW ds-1 DS -4 LW DS DS -4 ADDI ds-0 ds-1 ds-0 XOR ds-0 DS 0 SW ] }
    { fixnum-bitnot [ ds-0 DS 0 LW ds-0 ds-0 tag-mask get bitnot XORI ds-0 DS 0 SW ] }
    { fixnum*fast [ ds-0 DS 0 LW ds-1 DS -4 LW DS DS -4 ADDI
        ds-0 ds-0 tag-bits get SRAI ds-0 ds-1 ds-0 MUL ds-0 DS 0 SW ] }
    { fixnum+ [
        arg2 DS 0 LW arg1 DS -4 LW DS DS -4 ADDI save-context
        ds-0 arg1 arg2 ADD ds-0 DS 0 SW
        temp arg1 ds-0 XOR temp2 arg2 ds-0 XOR temp temp temp2 AND
        [ temp ZERO rot BGE ] [ arg3 VM MV "overflow_fixnum_add" native-call* ] jit-conditional*
    ] }
    { fixnum- [
        arg2 DS 0 LW arg1 DS -4 LW DS DS -4 ADDI save-context
        ds-0 arg1 arg2 SUB ds-0 DS 0 SW
        temp arg1 arg2 XOR temp2 arg1 ds-0 XOR temp temp temp2 AND
        [ temp ZERO rot BGE ] [ arg3 VM MV "overflow_fixnum_subtract" native-call* ] jit-conditional*
    ] }
    { fixnum* [
        arg2 DS 0 LW arg1 DS -4 LW DS DS -4 ADDI save-context
        arg1 arg1 tag-bits get SRAI ds-0 arg1 arg2 MUL ds-0 DS 0 SW
        temp arg1 arg2 MULH temp2 ds-0 31 SRAI
        [ temp temp2 rot BEQ ] [
            arg2 arg2 tag-bits get SRAI arg3 VM MV "overflow_fixnum_multiply" native-call*
        ] jit-conditional*
    ] }
    { fixnum-mod [ ds-0 DS 0 LW ds-1 DS -4 LW DS DS -4 ADDI
        check-divisor remainder ds-1 ds-0 REM remainder DS 0 SW ] }
    { fixnum/i-fast [ ds-0 DS 0 LW ds-1 DS -4 LW DS DS -4 ADDI
        check-divisor quotient ds-1 ds-0 DIV
        quotient quotient tag-bits get SLLI quotient DS 0 SW ] }
    { fixnum/mod-fast [ ds-0 DS 0 LW ds-1 DS -4 LW check-divisor
        temp ds-1 ds-0 DIV remainder ds-1 ds-0 REM
        quotient temp tag-bits get SLLI quotient DS -4 SW remainder DS 0 SW ] }
    { fixnum-shift-fast [
        ds-0 DS 0 LW ds-1 DS -4 LW DS DS -4 ADDI ds-0 ds-0 tag-bits get SRAI
        temp1 ds-1 ds-0 SLL
        [ ds-0 ZERO rot BGE ] [
            ds-0 ds-0 NEG temp1 ds-1 ds-0 SRA temp1 temp1 tag-mask get bitnot ANDI
        ] jit-conditional*
        temp1 DS 0 SW
    ] }
    { slot [
        ds-0 DS 0 LW ds-1 DS -4 LW DS DS -4 ADDI
        ds-0 ds-0 tag-bits get 2 - SRAI ds-1 ds-1 tag-mask get bitnot ANDI
        temp ds-1 ds-0 ADD ds-0 temp 0 LW ds-0 DS 0 SW
    ] }
    { string-nth-fast [
        ds-0 DS 0 LW ds-1 DS -4 LW DS DS -4 ADDI
        ds-1 ds-1 tag-bits get SRAI temp ds-0 ds-1 ADD
        ds-0 temp string-offset LBU ds-0 ds-0 tag-bits get SLLI ds-0 DS 0 SW
    ] }
    { set-callstack [
        ds-0 pop-ds bottom CTX context-callstack-bottom-offset LW
        src ds-0 callstack-top-offset ADDI temp ds-0 callstack-length-offset LW
        temp temp tag-bits get SRAI top bottom temp SUB SP top MV
        copy-linked-callstack epilog RET
    ] }
    { (set-context) [
        ds-0 pop-ds ds-0 ds-0 alien-offset LW ds-1 pop-ds
        NOP temp here-address
        AT FP MV FP FP -16 ADDI AT FP 0 SW temp FP 4 SW save-context
        CTX ds-0 MV CTX VM vm-context-offset SW
        FP CTX context-callstack-top-offset LW FP FP 0 LW
        load-stacks ds-1 push-ds
    ] }
    { (set-context-and-delete) [
        arg1 VM MV "delete_context" native-call
        ds-0 pop-ds ds-0 ds-0 alien-offset LW ds-1 pop-ds
        CTX ds-0 MV CTX VM vm-context-offset SW
        FP CTX context-callstack-top-offset LW FP FP 0 LW
        load-stacks ds-1 push-ds
    ] }
    { (start-context) [
        save-context arg1 VM MV "new_context" native-call* IP1 RETURN MV
        ds-0 pop-ds ds-1 pop-ds NOP temp here-address
        AT FP MV FP FP -16 ADDI AT FP 0 SW temp FP 4 SW save-context
        CTX IP1 MV CTX VM vm-context-offset SW
        FP CTX context-callstack-top-offset LW load-stacks
        ds-1 push-ds arg1 ds-0 MV temp arg1 quot-entry-point-offset LW temp JR
    ] }
    { (start-context-and-delete) [
        save-context arg1 VM MV "reset_context" native-call*
        FP CTX context-callstack-top-offset LW load-stacks
        arg1 pop-ds temp arg1 quot-entry-point-offset LW temp JR
    ] }
} define-sub-primitives

[ "bootstrap.assembler.hppa" forget-vocab ] with-compilation-unit
