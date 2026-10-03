! Copyright (C) 2026 Factor authors.
! See https://factorcode.org/license.txt for BSD license.
USING: assocs bootstrap.image.private compiler.codegen.relocation
compiler.constants compiler.units cpu.riscv.64.assembler
cpu.riscv.64.assembler.registers generic.single.private kernel
kernel.private layouts literals locals locals.backend make math math.bitwise
math.private namespaces sequences slots.private strings.private
threads.private vocabs ;
FROM: cpu.riscv.64.assembler.registers => cache ;
IN: bootstrap.assembler.riscv

8 \ cell set
big-endian off

: save-context ( -- )
    FP CTX context-callstack-top-offset SD
    DS CTX context-datastack-offset SD
    RS CTX context-retainstack-offset SD ;
: load-stacks ( -- )
    DS CTX context-datastack-offset LD
    RS CTX context-retainstack-offset LD ;
: prolog ( -- )
    SP SP -16 ADDI FP SP 0 SD RA SP 8 SD FP SP MV ;
: epilog ( -- )
    FP SP 0 LD RA SP 8 LD SP SP 16 ADDI ;
: native-call ( name -- )
    f IP0 load-address rel-dlsym RA TRAMPOLINE 0 JALR ;
: native-call* ( name -- ) native-call load-stacks ;
: pop-ds ( rd -- ) DS 0 LD DS DS -8 ADDI ;
: push-ds ( rs -- ) DS DS 8 ADDI DS 0 SD ;
: >r ( -- ) ds-0 pop-ds RS RS 8 ADDI ds-0 RS 0 SD ;
: r> ( -- ) ds-0 RS 0 LD RS RS -8 ADDI ds-0 push-ds ;
: tail-address ( -- ) PIC-TAIL 0 AUIPC PIC-TAIL PIC-TAIL 16 ADDI ;
: check-divisor ( -- )
    [ ds-0 ZERO rot BNE ] [
        save-context arg1 VM MV "divide_by_zero" native-call
    ] jit-conditional* ;

[ prolog ] JIT-PROLOG jit-define
[ save-context arg1 VM MV f native-call* ] JIT-PRIMITIVE jit-define
[ tail-address f jump-relative rel-word-pic-tail ] JIT-WORD-JUMP jit-define
[ f call-relative rel-word-pic ] JIT-WORD-CALL jit-define
[
    ds-0 pop-ds temp \ f type-number LI
    [ ds-0 temp rot BEQ ] [ f jump-relative rel-word ] jit-conditional*
    f jump-relative rel-word
] JIT-IF jit-define
[ SAFEPOINT SAFEPOINT 0 SD ] JIT-SAFEPOINT jit-define
[ epilog ] JIT-EPILOG jit-define
[ RET ] JIT-RETURN jit-define
[ f ds-0 load-address rel-literal ds-0 push-ds ] JIT-PUSH-LITERAL jit-define
[ >r f call-relative rel-word r> ] JIT-DIP jit-define
[ >r >r f call-relative rel-word r> r> ] JIT-2DIP jit-define
[ >r >r >r f call-relative rel-word r> r> r> ] JIT-3DIP jit-define
[ temp pop-ds temp temp word-entry-point-offset LD temp JR ] JIT-EXECUTE jit-define

! The snapshot of a0-a7 precedes native stack arguments for va_list.
:: jit-callback-stub ( varargs? -- )
    varargs? [
        SP SP -64 ADDI
        ${ A0 A1 A2 A3 A4 A5 A6 A7 } [ 8 * SP swap SD ] each-index
    ] when
    SP SP -112 ADDI
    ${ S0 S1 S2 S3 S4 S5 S6 S7 S8 S9 S10 S11 }
    [ 8 * SP swap SD ] each-index
    RA SP 96 SD
    0 VM load-address rel-vm
    CTX VM vm-context-offset LD CTX SP 104 SD
    SAFEPOINT load-address rel-safepoint
    TRAMPOLINE load-address rel-trampoline
    TRAMPOLINE2 load-address rel-trampoline2
    CACHE-MISS load-address rel-inline-cache-miss
    MEGA-HITS load-address rel-megamorphic-cache-hits
    CTX VM vm-spare-context-offset LD CTX VM vm-context-offset SD
    SP CTX context-callstack-save-offset SD
    SP CTX context-callstack-bottom-offset LD SP SP 16 ADDI
    FP ZERO MV load-stacks
    f temp load-address rel-word RA temp 0 JALR
    SP CTX context-callstack-save-offset LD
    RA SP 96 LD CTX SP 104 LD CTX VM vm-context-offset SD
    ${ S0 S1 S2 S3 S4 S5 S6 S7 S8 S9 S10 S11 }
    [ 8 * SP swap LD ] each-index
    SP SP 112 ADDI varargs? [ SP SP 64 ADDI ] when RET ;
[ f jit-callback-stub ] CALLBACK-STUB jit-define
[ t jit-callback-stub ] make-jit-no-params
CALLBACK-STUB special-objects get at swap suffix
CALLBACK-STUB special-objects get set-at

[ obj DS 0 LD f rc-absolute-riscv-i rel-untagged ] PIC-LOAD jit-define
[ type obj tag-mask get ANDI temp2 type MV ] PIC-TAG jit-define
[
    type obj tag-mask get ANDI temp tuple type-number LI
    [ type temp rot BNE ] [ type obj tuple-class-offset LD ] jit-conditional*
] PIC-TUPLE jit-define
[ f temp load-address rel-untagged temp2 type temp XOR ] PIC-CHECK-TAG jit-define
[ f temp load-address rel-literal temp2 type temp XOR ] PIC-CHECK-TUPLE jit-define
[ [ temp2 ZERO rot BNE ] [ f jump-relative rel-word ] jit-conditional* ] PIC-HIT jit-define
[ PIC-TAIL RA MV f jump-relative rel-word ] PIC-MISS-JUMP jit-define
[ f jump-relative rel-word ] PIC-MISS-TAIL-JUMP jit-define
[
    type obj tag-mask get ANDI type type tag-bits get SLLI
    temp tuple type-number tag-fixnum LI
    [ type temp rot BNE ] [ type obj tuple-class-offset LD ] jit-conditional*
    f cache load-address rel-literal
    temp type mega-cache-size get 1 - bootstrap-cells ANDI
    cache cache temp ADD temp cache array-start-offset LD
    [ type temp rot BNE ] [
        temp MEGA-HITS 0 LD temp temp 1 ADDI temp MEGA-HITS 0 SD
        temp cache array-start-offset bootstrap-cell + LD
        temp temp word-entry-point-offset LD temp JR
    ] jit-conditional*
] MEGA-LOOKUP jit-define

[ arg1 pop-ds temp arg1 quot-entry-point-offset LD ]
[ RA temp 0 JALR ] [ temp JR ] \ (call) define-combinator-primitive
[ temp pop-ds temp temp word-entry-point-offset LD ]
[ RA temp 0 JALR ] [ temp JR ] \ (execute) define-combinator-primitive
[ save-context arg2 VM MV "lazy_jit_compile" native-call*
  temp RETURN quot-entry-point-offset LD ]
[ RA temp 0 JALR ] [ temp JR ] \ lazy-jit-compile define-combinator-primitive
[ save-context arg1 FP 8 LD arg2 VM MV IP0 CACHE-MISS MV
  RA TRAMPOLINE 0 JALR load-stacks ]
[ RA RETURN 0 JALR ] [ RETURN JR ] \ inline-cache-miss define-combinator-primitive
[ save-context arg1 PIC-TAIL MV arg2 VM MV IP0 CACHE-MISS MV
  RA TRAMPOLINE 0 JALR load-stacks ]
[ RA RETURN 0 JALR ] [ RETURN JR ] \ inline-cache-miss-tail define-combinator-primitive

! Save every register that Factor or an asynchronous native handler can use.
: jit-signal-handler ( -- )
    SP SP -512 ADDI
    32 <iota> [ dup 2 = [ drop ] [
        dup int-register boa SP rot 8 * SD
    ] if ] each
    32 <iota> [ dup fp-register boa SP rot 8 * 256 + FSD ] each
    temp 3 CSRR temp SP 16 SD
    save-context IP0 VM vm-signal-handler-addr-offset LD RA TRAMPOLINE 0 JALR
    temp SP 16 LD 3 temp CSRW
    32 <iota> [ dup fp-register boa SP rot 8 * 256 + FLD ] each
    32 <iota> [ dup 2 = [ drop ] [
        dup int-register boa SP rot 8 * LD
    ] if ] each
    SP SP 512 ADDI ;
:: jit-compare ( branch -- )
    ds-0 DS 0 LD ds-1 DS -8 LD DS DS -8 ADDI
    t temp load-address rel-literal
    temp1 \ f type-number LI
    ds-1 ds-0 8 branch call
    temp1 temp MV temp1 DS 0 SD ; inline

{
    { c-to-factor [
        arg2 arg1 MV arg1 VM MV "begin_callback" native-call
        temp RETURN quot-entry-point-offset LD RA temp 0 JALR
        arg1 VM MV "end_callback" native-call
    ] }
    { unwind-native-frames [
        SP arg2 MV epilog 0 VM load-address rel-vm
        CTX VM vm-context-offset LD load-stacks
        SAFEPOINT load-address rel-safepoint
        TRAMPOLINE load-address rel-trampoline
        TRAMPOLINE2 load-address rel-trampoline2
        CACHE-MISS load-address rel-inline-cache-miss
        MEGA-HITS load-address rel-megamorphic-cache-hits
        ZERO VM vm-fault-flag-offset SD
        temp arg1 quot-entry-point-offset LD temp JR
    ] }
    { inline-cache-miss-resume [
        prolog save-context arg1 PIC-TAIL MV arg2 VM MV IP0 CACHE-MISS MV
        RA TRAMPOLINE 0 JALR load-stacks epilog RETURN JR
    ] }
    { fpu-state [ RETURN 3 CSRR 3 ZERO CSRW ] }
    { set-fpu-state [ 3 arg1 CSRW ] }
    { leaf-signal-handler [
        FP SP 16 SD RA SP 24 SD
        temp SP 16 ADDI temp SP 0 SD FP SP MV
        jit-signal-handler
        IP0 SP 8 LD FP SP 16 LD RA SP 24 LD SP SP 32 ADDI IP0 JR
    ] }
    { signal-handler [
        FP SP 0 SD FP SP MV jit-signal-handler
        FP SP 0 LD IP0 SP 8 LD SP SP 16 ADDI IP0 JR
    ] }
    { drop [ DS DS -8 ADDI ] }
    { 2drop [ DS DS -16 ADDI ] }
    { 3drop [ DS DS -24 ADDI ] }
    { 4drop [ DS DS -32 ADDI ] }
    { dup [ ds-0 DS 0 LD DS DS 8 ADDI ds-0 DS -8 SD ds-0 DS 0 SD ] }
    { over [ ds-0 DS 0 LD ds-1 DS -8 LD DS DS 8 ADDI ds-1 DS -16 SD ds-0 DS -8 SD ds-1 DS 0 SD ] }
    { pick [ ds-0 DS 0 LD ds-1 DS -8 LD ds-2 DS -16 LD DS DS 8 ADDI ds-2 DS -24 SD ds-1 DS -16 SD ds-0 DS -8 SD ds-2 DS 0 SD ] }
    { swap [ ds-0 DS 0 LD ds-1 DS -8 LD ds-0 DS -8 SD ds-1 DS 0 SD ] }
    { swapd [ ds-0 DS 0 LD ds-1 DS -8 LD ds-2 DS -16 LD ds-1 DS -16 SD ds-2 DS -8 SD ds-0 DS 0 SD ] }
    { nip [ ds-0 DS 0 LD ds-1 DS -8 LD DS DS -8 ADDI ds-0 DS 0 SD ] }
    { 2nip [ ds-0 DS 0 LD ds-1 DS -8 LD ds-2 DS -16 LD DS DS -16 ADDI ds-0 DS 0 SD ] }
    { 2dup [ ds-0 DS 0 LD ds-1 DS -8 LD DS DS 16 ADDI ds-1 DS -24 SD ds-0 DS -16 SD ds-1 DS -8 SD ds-0 DS 0 SD ] }
    { dupd [ ds-0 DS 0 LD ds-1 DS -8 LD DS DS 8 ADDI ds-1 DS -16 SD ds-1 DS -8 SD ds-0 DS 0 SD ] }
    { 3dup [ ds-0 DS 0 LD ds-1 DS -8 LD ds-2 DS -16 LD DS DS 24 ADDI ds-2 DS -40 SD ds-1 DS -32 SD ds-0 DS -24 SD ds-2 DS -16 SD ds-1 DS -8 SD ds-0 DS 0 SD ] }
    { 4dup [ ds-0 DS 0 LD ds-1 DS -8 LD ds-2 DS -16 LD ds-3 DS -24 LD DS DS 32 ADDI ds-3 DS -56 SD ds-2 DS -48 SD ds-1 DS -40 SD ds-0 DS -32 SD ds-3 DS -24 SD ds-2 DS -16 SD ds-1 DS -8 SD ds-0 DS 0 SD ] }
    { rot [ ds-0 DS 0 LD ds-1 DS -8 LD ds-2 DS -16 LD ds-1 DS -16 SD ds-0 DS -8 SD ds-2 DS 0 SD ] }
    { -rot [ ds-0 DS 0 LD ds-1 DS -8 LD ds-2 DS -16 LD ds-0 DS -16 SD ds-2 DS -8 SD ds-1 DS 0 SD ] }
    { eq? [ [ BNE ] jit-compare ] }
    { fixnum< [ [ BGE ] jit-compare ] }
    { fixnum<= [ [ swapd BLT ] jit-compare ] }
    { fixnum> [ [ swapd BGE ] jit-compare ] }
    { fixnum>= [ [ BLT ] jit-compare ] }
    { tag [ ds-0 DS 0 LD ds-0 ds-0 tag-mask get ANDI
        ds-0 ds-0 tag-bits get SLLI ds-0 DS 0 SD ] }
    { drop-locals [ ds-0 pop-ds ds-0 ds-0 tag-bits get 3 - SRAI RS RS ds-0 SUB ] }
    { get-local [ ds-0 DS 0 LD ds-0 ds-0 tag-bits get 3 - SRAI
        temp RS ds-0 ADD ds-0 temp 0 LD ds-0 DS 0 SD ] }
    { load-local [ >r ] }
    { both-fixnums? [
        ds-0 DS 0 LD ds-1 DS -8 LD DS DS -8 ADDI
        ds-0 ds-0 ds-1 OR ds-0 ds-0 tag-mask get ANDI
        temp 1 tag-fixnum LI temp1 \ f type-number LI
        ds-0 ZERO 8 BNE temp1 temp MV temp1 DS 0 SD
    ] }
    { fixnum+fast [ ds-0 DS 0 LD ds-1 DS -8 LD DS DS -8 ADDI ds-0 ds-1 ds-0 ADD ds-0 DS 0 SD ] }
    { fixnum-fast [ ds-0 DS 0 LD ds-1 DS -8 LD DS DS -8 ADDI ds-0 ds-1 ds-0 SUB ds-0 DS 0 SD ] }
    { fixnum-bitand [ ds-0 DS 0 LD ds-1 DS -8 LD DS DS -8 ADDI ds-0 ds-1 ds-0 AND ds-0 DS 0 SD ] }
    { fixnum-bitor [ ds-0 DS 0 LD ds-1 DS -8 LD DS DS -8 ADDI ds-0 ds-1 ds-0 OR ds-0 DS 0 SD ] }
    { fixnum-bitxor [ ds-0 DS 0 LD ds-1 DS -8 LD DS DS -8 ADDI ds-0 ds-1 ds-0 XOR ds-0 DS 0 SD ] }
    { fixnum-bitnot [ ds-0 DS 0 LD ds-0 ds-0 tag-mask get bitnot XORI ds-0 DS 0 SD ] }
    { fixnum*fast [ ds-0 DS 0 LD ds-1 DS -8 LD DS DS -8 ADDI
        ds-0 ds-0 tag-bits get SRAI ds-0 ds-1 ds-0 MUL ds-0 DS 0 SD ] }
    { fixnum+ [
        arg2 DS 0 LD arg1 DS -8 LD DS DS -8 ADDI save-context
        ds-0 arg1 arg2 ADD ds-0 DS 0 SD
        temp arg1 ds-0 XOR temp2 arg2 ds-0 XOR temp temp temp2 AND
        [ temp ZERO rot BGE ] [ arg3 VM MV "overflow_fixnum_add" native-call* ] jit-conditional*
    ] }
    { fixnum- [
        arg2 DS 0 LD arg1 DS -8 LD DS DS -8 ADDI save-context
        ds-0 arg1 arg2 SUB ds-0 DS 0 SD
        temp arg1 arg2 XOR temp2 arg1 ds-0 XOR temp temp temp2 AND
        [ temp ZERO rot BGE ] [ arg3 VM MV "overflow_fixnum_subtract" native-call* ] jit-conditional*
    ] }
    { fixnum* [
        arg2 DS 0 LD arg1 DS -8 LD DS DS -8 ADDI save-context
        arg1 arg1 tag-bits get SRAI ds-0 arg1 arg2 MUL ds-0 DS 0 SD
        temp arg1 arg2 MULH temp2 ds-0 63 SRAI
        [ temp temp2 rot BEQ ] [
            arg2 arg2 tag-bits get SRAI arg3 VM MV "overflow_fixnum_multiply" native-call*
        ] jit-conditional*
    ] }
    { fixnum-mod [ ds-0 DS 0 LD ds-1 DS -8 LD DS DS -8 ADDI
        check-divisor remainder ds-1 ds-0 REM remainder DS 0 SD ] }
    { fixnum/i-fast [ ds-0 DS 0 LD ds-1 DS -8 LD DS DS -8 ADDI
        check-divisor quotient ds-1 ds-0 DIV
        quotient quotient tag-bits get SLLI quotient DS 0 SD ] }
    { fixnum/mod-fast [ ds-0 DS 0 LD ds-1 DS -8 LD check-divisor
        temp ds-1 ds-0 DIV remainder ds-1 ds-0 REM
        quotient temp tag-bits get SLLI quotient DS -8 SD remainder DS 0 SD ] }
    { fixnum-shift-fast [
        ds-0 DS 0 LD ds-1 DS -8 LD DS DS -8 ADDI ds-0 ds-0 tag-bits get SRAI
        temp1 ds-1 ds-0 SLL ds-0 ZERO 16 BGE
        ds-0 ds-0 NEG temp1 ds-1 ds-0 SRA temp1 temp1 tag-mask get bitnot ANDI
        temp1 DS 0 SD
    ] }
    { slot [
        ds-0 DS 0 LD ds-1 DS -8 LD DS DS -8 ADDI
        ds-0 ds-0 tag-bits get 3 - SRAI ds-1 ds-1 tag-mask get bitnot ANDI
        temp ds-1 ds-0 ADD ds-0 temp 0 LD ds-0 DS 0 SD
    ] }
    { string-nth-fast [
        ds-0 DS 0 LD ds-1 DS -8 LD DS DS -8 ADDI
        ds-1 ds-1 tag-bits get SRAI temp ds-0 ds-1 ADD
        ds-0 temp string-offset LBU ds-0 ds-0 tag-bits get SLLI ds-0 DS 0 SD
    ] }
    { set-callstack [
        ds-0 pop-ds bottom CTX context-callstack-bottom-offset LD
        src ds-0 callstack-top-offset ADDI temp ds-0 callstack-length-offset LD
        temp temp tag-bits get SRAI top bottom temp SUB SP top MV
        ! Copied callstacks contain relative frame links; restore them as
        ! each frame record is reached, copying its payload unchanged.
        top bottom 60 BGEU
        temp1 src 0 LD temp2 src 8 LD FP top temp1 ADD
        FP top 0 SD temp2 top 8 SD src src 16 ADDI top top 16 ADDI
        top FP 24 BGEU
        temp1 src 0 LD temp1 top 0 SD src src 8 ADDI top top 8 ADDI -20 J
        top bottom -56 BLTU
        epilog RET
    ] }
    { (set-context) [
        ds-0 pop-ds ds-0 ds-0 alien-offset LD ds-1 pop-ds
        temp 0 AUIPC
        SP SP -16 ADDI FP SP 0 SD temp SP 8 SD FP SP MV save-context
        CTX ds-0 MV CTX VM vm-context-offset SD
        SP CTX context-callstack-top-offset LD FP SP 0 LD SP SP 16 ADDI
        load-stacks ds-1 push-ds
    ] }
    { (set-context-and-delete) [
        arg1 VM MV "delete_context" native-call
        ds-0 pop-ds ds-0 ds-0 alien-offset LD ds-1 pop-ds
        CTX ds-0 MV CTX VM vm-context-offset SD
        SP CTX context-callstack-top-offset LD FP SP 0 LD SP SP 16 ADDI
        load-stacks ds-1 push-ds
    ] }
    { (start-context) [
        save-context arg1 VM MV "new_context" native-call*
        ds-0 pop-ds ds-1 pop-ds temp 0 AUIPC
        SP SP -16 ADDI FP SP 0 SD temp SP 8 SD FP SP MV save-context
        CTX RETURN MV CTX VM vm-context-offset SD
        FP CTX context-callstack-top-offset LD SP FP MV load-stacks
        ds-1 push-ds arg1 ds-0 MV temp arg1 quot-entry-point-offset LD temp JR
    ] }
    { (start-context-and-delete) [
        save-context arg1 VM MV "reset_context" native-call*
        FP CTX context-callstack-top-offset LD SP FP MV load-stacks
        arg1 pop-ds temp arg1 quot-entry-point-offset LD temp JR
    ] }
} define-sub-primitives

[ "bootstrap.assembler.riscv" forget-vocab ] with-compilation-unit
