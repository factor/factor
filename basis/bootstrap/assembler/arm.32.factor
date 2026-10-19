! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: assocs bootstrap.image.private compiler.codegen.relocation
compiler.constants compiler.units cpu.arm.32.assembler
cpu.arm.32.assembler.registers cpu.arm.32.compiler-assembler generic.single.private kernel
kernel.private layouts literals locals locals.backend make math math.bitwise
math.private namespaces sequences slots.private strings.private
threads.private vocabs ;
FROM: cpu.arm.32.assembler => B ;
FROM: cpu.arm.32.assembler.registers => cache ;
IN: bootstrap.assembler.arm

4 \ cell set
big-endian off
emit-bytecode? on
have-BX? on
have-BLX? on

: save-context ( -- )
    FP CTX context-callstack-top-offset <+> STR
    DS CTX context-datastack-offset <+> STR
    RS CTX context-retainstack-offset <+> STR ;
: load-stacks ( -- )
    DS CTX context-datastack-offset <+> LDR
    RS CTX context-retainstack-offset <+> LDR ;
: prolog ( -- )
    SP SP 16 SUB FP SP 0 <+> STR LR SP 4 <+> STR FP SP MOV ;
: epilog ( -- )
    FP SP 0 <+> LDR LR SP 4 <+> LDR SP SP 16 ADD ;
: native-call ( name -- )
    f IP0 load-address rel-dlsym TRAMPOLINE BLX ;
: native-call* ( name -- ) native-call load-stacks ;
: pop-ds ( rd -- ) DS 4 <-!> LDR ;
: push-ds ( rd -- ) DS 4 <!+> STR ;
: >r ( -- ) ds-0 pop-ds ds-0 RS 4 <!+> STR ;
: r> ( -- ) ds-0 RS 4 <-!> LDR ds-0 push-ds ;
: tail-address ( -- ) PIC-TAIL PC 4 ADD ;
! jit-conditional* supplies a byte distance from the instruction. ARM PC is +8.
: branch-ne ( distance -- ) 8 - -2 shift NE B ;
: branch-eq ( distance -- ) 8 - -2 shift EQ B ;
: branch-vc ( distance -- ) 8 - -2 shift VC B ;
:: jit-compare ( cc -- )
    ds-0 pop-ds ds-1 DS 0 <+> LDR t temp load-address rel-literal
    ds-1 ds-0 CMP ds-0 \ f type-number MOV cc call( -- ) ds-0 temp MOV
    ds-0 DS 0 <+> STR ;


[ prolog ] JIT-PROLOG jit-define
[ save-context arg1 VM MOV f native-call* ] JIT-PRIMITIVE jit-define
[ tail-address f jump-address rel-word-pic-tail ] JIT-WORD-JUMP jit-define
[ f call-address rel-word-pic ] JIT-WORD-CALL jit-define
[
    ds-0 pop-ds ds-0 \ f type-number CMP
    [ branch-eq ] [ f jump-address rel-word ] jit-conditional*
    f jump-address rel-word
] JIT-IF jit-define
[ SAFEPOINT SAFEPOINT 0 <+> STR ] JIT-SAFEPOINT jit-define
[ epilog ] JIT-EPILOG jit-define
[ LR BX ] JIT-RETURN jit-define
[ f ds-0 load-address rel-literal ds-0 push-ds ] JIT-PUSH-LITERAL jit-define
[ >r f call-address rel-word r> ] JIT-DIP jit-define
[ >r >r f call-address rel-word r> r> ] JIT-2DIP jit-define
[ >r >r >r f call-address rel-word r> r> r> ] JIT-3DIP jit-define
[ temp pop-ds temp temp word-entry-point-offset <+> LDR temp BX ] JIT-EXECUTE jit-define

:: jit-callback-stub ( varargs? -- )
    varargs? [ ${ R0 R1 R2 R3 } PUSH ] when
    VPUSH-D8-D15 SP SP 48 SUB
    ${ R4 R5 R6 R7 R8 R9 R10 R11 } [ 4 * SP swap <+> STR ] each-index
    LR SP 32 <+> STR
    0 VM load-address rel-vm
    CTX VM vm-context-offset <+> LDR CTX SP 36 <+> STR
    SAFEPOINT load-address rel-safepoint
    TRAMPOLINE load-address rel-trampoline
    IP1 load-address rel-trampoline2
    IP0 load-address rel-inline-cache-miss
    IP0 load-address rel-megamorphic-cache-hits
    CTX VM vm-spare-context-offset <+> LDR CTX VM vm-context-offset <+> STR
    SP CTX context-callstack-save-offset <+> STR
    SP CTX context-callstack-bottom-offset <+> LDR SP SP 16 ADD
    FP 0 MOV load-stacks
    f call-address rel-word
    SP CTX context-callstack-save-offset <+> LDR
    LR SP 32 <+> LDR CTX SP 36 <+> LDR CTX VM vm-context-offset <+> STR
    ${ R4 R5 R6 R7 R8 R9 R10 R11 } [ 4 * SP swap <+> LDR ] each-index
    SP SP 48 ADD VPOP-D8-D15 varargs? [ SP SP 16 ADD ] when LR BX ;
[ f jit-callback-stub ] CALLBACK-STUB jit-define
[ t jit-callback-stub ] make-jit-no-params
CALLBACK-STUB special-objects get at swap suffix
CALLBACK-STUB special-objects get set-at

[ f temp load-address rel-untagged obj DS temp <+> LDR ] PIC-LOAD jit-define
[ type obj tag-mask get AND temp2 type MOV ] PIC-TAG jit-define
[
    type obj tag-mask get AND type tuple type-number CMP
    [ branch-ne ] [ type obj tuple-class-offset <+> LDR ] jit-conditional*
] PIC-TUPLE jit-define
[ f temp load-address rel-untagged temp2 type temp EOR ] PIC-CHECK-TAG jit-define
[ f temp load-address rel-literal temp2 type temp EOR ] PIC-CHECK-TUPLE jit-define
[ temp2 0 CMP [ branch-ne ] [ f jump-address rel-word ] jit-conditional* ] PIC-HIT jit-define
[ PIC-TAIL LR MOV f jump-address rel-word ] PIC-MISS-JUMP jit-define
[ f jump-address rel-word ] PIC-MISS-TAIL-JUMP jit-define
[
    type obj tag-mask get AND type type tag-bits get <LSL> MOV
    type tuple type-number tag-fixnum CMP
    [ branch-ne ] [ type obj tuple-class-offset <+> LDR ] jit-conditional*
    f cache load-address rel-literal
    temp type 1 <LSR> MOV
    temp temp mega-cache-size get 1 - bootstrap-cells AND
    cache cache temp ADD temp cache array-start-offset <+> LDR type temp CMP
    [ branch-ne ] [
        temp load-address rel-megamorphic-cache-hits
        temp2 temp 0 <+> LDR temp2 temp2 1 ADD temp2 temp 0 <+> STR
        temp cache array-start-offset bootstrap-cell + <+> LDR
        temp temp word-entry-point-offset <+> LDR temp BX
    ] jit-conditional*
] MEGA-LOOKUP jit-define

[ arg1 pop-ds temp arg1 quot-entry-point-offset <+> LDR ]
[ temp BLX ] [ temp BX ] \ (call) define-combinator-primitive
[ temp pop-ds temp temp word-entry-point-offset <+> LDR ]
[ temp BLX ] [ temp BX ] \ (execute) define-combinator-primitive
[ save-context arg2 VM MOV "lazy_jit_compile" native-call*
  temp RETURN quot-entry-point-offset <+> LDR ]
[ temp BLX ] [ temp BX ] \ lazy-jit-compile define-combinator-primitive
[ save-context arg1 FP 4 <+> LDR arg2 VM MOV
  "inline_cache_miss" native-call* ]
[ RETURN BLX ] [ RETURN BX ] \ inline-cache-miss define-combinator-primitive
[ save-context arg1 PIC-TAIL MOV arg2 VM MOV
  "inline_cache_miss" native-call* ]
[ RETURN BLX ] [ RETURN BX ] \ inline-cache-miss-tail define-combinator-primitive

! 56 GPR bytes + 8 FPSCR bytes + 128 VFP bytes = 192; leaf wrapper = 32.
: jit-signal-handler ( -- )
    ${ R0 R1 R2 R3 R4 R5 R6 R7 R8 R9 R10 R11 R12 LR } PUSH
    SP SP 8 SUB temp VMRS temp SP 0 <+> STR
    temp MRS-APSR temp SP 4 <+> STR VPUSH-D0-D15
    save-context IP0 VM vm-signal-handler-addr-offset <+> LDR TRAMPOLINE BLX
    VPOP-D0-D15 temp SP 0 <+> LDR temp VMSR
    temp SP 4 <+> LDR temp MSR-APSR SP SP 8 ADD
    ${ R0 R1 R2 R3 R4 R5 R6 R7 R8 R9 R10 R11 R12 LR } POP ;

{
    { c-to-factor [
        arg2 arg1 MOV arg1 VM MOV "begin_callback" native-call
        temp RETURN quot-entry-point-offset <+> LDR temp BLX
        arg1 VM MOV "end_callback" native-call
    ] }
    { unwind-native-frames [
        SP arg2 MOV epilog 0 VM load-address rel-vm
        CTX VM vm-context-offset <+> LDR load-stacks
        SAFEPOINT load-address rel-safepoint TRAMPOLINE load-address rel-trampoline
        temp 0 MOV temp VM vm-fault-flag-offset <+> STR
        temp arg1 quot-entry-point-offset <+> LDR temp BX
    ] }
    { inline-cache-miss-resume [
        prolog save-context arg1 PIC-TAIL MOV arg2 VM MOV
        "inline_cache_miss" native-call* epilog RETURN BX
    ] }
    { fpu-state [ RETURN VMRS temp 0 MOV temp VMSR ] }
    { set-fpu-state [ arg1 VMSR ] }
    { leaf-signal-handler [
        FP SP 16 <+> STR LR SP 20 <+> STR temp SP 16 ADD temp SP 0 <+> STR FP SP MOV
        jit-signal-handler
        IP0 SP 4 <+> LDR FP SP 16 <+> LDR LR SP 20 <+> LDR SP SP 32 ADD IP0 BX
    ] }
    { signal-handler [
        FP SP 0 <+> STR FP SP MOV jit-signal-handler
        FP SP 0 <+> LDR IP0 SP 4 <+> LDR SP SP 16 ADD IP0 BX
    ] }
    { drop [ DS DS 4 SUB ] }
    { 2drop [ DS DS 8 SUB ] }
    { 3drop [ DS DS 12 SUB ] }
    { 4drop [ DS DS 16 SUB ] }
    { dup [ ds-0 DS 0 <+> LDR ds-0 push-ds ] }
    { over [ ds-0 DS 4 <-> LDR ds-0 push-ds ] }
    { pick [ ds-0 DS 8 <-> LDR ds-0 push-ds ] }
    { swap [ ds-0 DS 0 <+> LDR ds-1 DS 4 <-> LDR ds-0 DS 4 <-> STR ds-1 DS 0 <+> STR ] }
    { 2dup [ ds-0 DS 0 <+> LDR ds-1 DS 4 <-> LDR ds-1 push-ds ds-0 push-ds ] }
    { 3dup [ ds-0 DS 0 <+> LDR ds-1 DS 4 <-> LDR ds-2 DS 8 <-> LDR ds-2 push-ds ds-1 push-ds ds-0 push-ds ] }
    { 4dup [ ds-0 DS 0 <+> LDR ds-1 DS 4 <-> LDR ds-2 DS 8 <-> LDR ds-3 DS 12 <-> LDR ds-3 push-ds ds-2 push-ds ds-1 push-ds ds-0 push-ds ] }
    { dupd [ ds-0 DS 0 <+> LDR ds-1 DS 4 <-> LDR ds-1 DS 0 <+> STR ds-0 push-ds ] }
    { swapd [ ds-1 DS 4 <-> LDR ds-2 DS 8 <-> LDR ds-1 DS 8 <-> STR ds-2 DS 4 <-> STR ] }
    { rot [ ds-0 DS 0 <+> LDR ds-1 DS 4 <-> LDR ds-2 DS 8 <-> LDR ds-1 DS 8 <-> STR ds-0 DS 4 <-> STR ds-2 DS 0 <+> STR ] }
    { -rot [ ds-0 DS 0 <+> LDR ds-1 DS 4 <-> LDR ds-2 DS 8 <-> LDR ds-0 DS 8 <-> STR ds-2 DS 4 <-> STR ds-1 DS 0 <+> STR ] }
    { nip [ ds-0 pop-ds ds-0 DS 0 <+> STR ] }
    { 2nip [ ds-0 pop-ds DS DS 4 SUB ds-0 DS 0 <+> STR ] }
    { eq? [ [ EQ ] jit-compare ] }
    { fixnum< [ [ LT ] jit-compare ] }
    { fixnum<= [ [ LE ] jit-compare ] }
    { fixnum> [ [ GT ] jit-compare ] }
    { fixnum>= [ [ GE ] jit-compare ] }
    { tag [ ds-0 DS 0 <+> LDR ds-0 ds-0 tag-mask get AND ds-0 ds-0 tag-bits get <LSL> MOV ds-0 DS 0 <+> STR ] }
    { both-fixnums? [
        ds-0 pop-ds ds-1 DS 0 <+> LDR temp ds-0 ds-1 ORR temp temp tag-mask get AND
        temp 0 CMP ds-0 \ f type-number MOV EQ ds-0 1 tag-fixnum MOV ds-0 DS 0 <+> STR
    ] }
    { fixnum-bitnot [ ds-0 DS 0 <+> LDR ds-0 ds-0 MVN ds-0 ds-0 tag-mask get BIC ds-0 DS 0 <+> STR ] }
    { fixnum+ [
        arg2 pop-ds arg1 DS 0 <+> LDR save-context temp2 arg1 arg2 S ADD temp2 DS 0 <+> STR
        [ branch-vc ] [ arg3 VM MOV "overflow_fixnum_add" native-call* ] jit-conditional*
    ] }
    { fixnum- [
        arg2 pop-ds arg1 DS 0 <+> LDR save-context temp2 arg1 arg2 S SUB temp2 DS 0 <+> STR
        [ branch-vc ] [ arg3 VM MOV "overflow_fixnum_subtract" native-call* ] jit-conditional*
    ] }
    { fixnum* [
        arg2 pop-ds arg1 DS 0 <+> LDR save-context
        arg1 arg1 tag-bits get <ASR> MOV temp1 temp2 arg1 arg2 SMULL temp1 DS 0 <+> STR
        temp2 temp1 31 <ASR> CMP
        [ branch-eq ] [ arg2 arg2 tag-bits get <ASR> MOV arg3 VM MOV "overflow_fixnum_multiply" native-call* ] jit-conditional*
    ] }
    { fixnum/i-fast [
        save-context arg1 VM MOV "primitive_fixnum_divint" native-call*
    ] }
    { fixnum/mod-fast [
        save-context arg1 VM MOV "primitive_fixnum_divmod" native-call*
    ] }
    { fixnum-mod [
        save-context arg1 VM MOV "primitive_fixnum_divmod" native-call*
        ds-0 pop-ds ds-0 DS 0 <+> STR
    ] }
    { fixnum-shift-fast [
        ds-0 pop-ds ds-1 DS 0 <+> LDR ds-0 ds-0 tag-bits get <ASR> MOV
        ds-0 0 CMP LT ds-0 ds-0 0 RSB ds-0 ds-0 31 AND
        GE temp1 ds-1 ds-0 <LSL> MOV LT temp1 ds-1 ds-0 <ASR> MOV
        temp1 temp1 tag-mask get BIC temp1 DS 0 <+> STR
    ] }
    { slot [
        ds-0 pop-ds ds-1 DS 0 <+> LDR ds-0 ds-0 tag-bits get 2 - <ASR> MOV
        ds-1 ds-1 tag-mask get BIC ds-0 ds-1 ds-0 <+> LDR ds-0 DS 0 <+> STR
    ] }
    { string-nth-fast [
        ds-0 pop-ds ds-1 DS 0 <+> LDR ds-1 ds-1 tag-bits get <ASR> MOV
        temp ds-0 ds-1 ADD ds-0 temp string-offset <+> LDRB
        ds-0 ds-0 tag-bits get <LSL> MOV ds-0 DS 0 <+> STR
    ] }
    { >r [ >r ] }
    { r> [ r> ] }
    { load-local [ >r ] }
    { drop-locals [ ds-0 pop-ds ds-0 ds-0 tag-bits get 2 - <ASR> MOV RS RS ds-0 SUB ] }
    { get-local [ ds-0 DS 0 <+> LDR ds-0 ds-0 tag-bits get 2 - <ASR> MOV ds-0 RS ds-0 <+> LDR ds-0 DS 0 <+> STR ] }
    { fixnum+fast [ ds-0 pop-ds ds-1 DS 0 <+> LDR ds-0 ds-1 ds-0 ADD ds-0 DS 0 <+> STR ] }
    { fixnum-fast [ ds-0 pop-ds ds-1 DS 0 <+> LDR ds-0 ds-1 ds-0 SUB ds-0 DS 0 <+> STR ] }
    { fixnum-bitand [ ds-0 pop-ds ds-1 DS 0 <+> LDR ds-0 ds-1 ds-0 AND ds-0 DS 0 <+> STR ] }
    { fixnum-bitor [ ds-0 pop-ds ds-1 DS 0 <+> LDR ds-0 ds-1 ds-0 ORR ds-0 DS 0 <+> STR ] }
    { fixnum-bitxor [ ds-0 pop-ds ds-1 DS 0 <+> LDR ds-0 ds-1 ds-0 EOR ds-0 DS 0 <+> STR ] }
    { fixnum*fast [ ds-0 pop-ds ds-1 DS 0 <+> LDR ds-0 ds-0 tag-bits get <ASR> MOV ds-0 ds-1 ds-0 MUL ds-0 DS 0 <+> STR ] }
    { set-callstack [
        ds-0 pop-ds arg2 ds-0 callstack-top-offset ADD
        temp ds-0 callstack-length-offset <+> LDR temp temp tag-bits get <ASR> MOV
        arg3 CTX context-callstack-bottom-offset <+> LDR arg4 arg3 temp SUB SP arg4 MOV
        arg4 arg3 CMP 15 CS B
        temp arg2 0 <+> LDR FP arg4 temp ADD FP arg4 0 <+> STR
        temp arg2 4 <+> LDR temp arg4 4 <+> STR arg2 arg2 8 ADD arg4 arg4 8 ADD
        arg4 FP CMP 4 CS B
        temp arg2 0 <+> LDR temp arg4 0 <+> STR arg2 arg2 4 ADD arg4 arg4 4 ADD -8 B
        arg4 arg3 CMP -17 CC B epilog LR BX
    ] }
    { (set-context) [
        ds-0 pop-ds ds-0 ds-0 alien-offset <+> LDR ds-1 pop-ds temp PC MOV
        SP SP 16 SUB FP SP 0 <+> STR temp SP 4 <+> STR FP SP MOV save-context
        CTX ds-0 MOV CTX VM vm-context-offset <+> STR
        SP CTX context-callstack-top-offset <+> LDR FP SP 0 <+> LDR SP SP 16 ADD
        load-stacks ds-1 push-ds
    ] }
    { (set-context-and-delete) [
        ! The current DS/RS contain the switch inputs; delete_context does
        ! not change them. Reloading unsaved context fields loses those inputs.
        arg1 VM MOV "delete_context" native-call
        ds-0 pop-ds ds-0 ds-0 alien-offset <+> LDR ds-1 pop-ds
        CTX ds-0 MOV CTX VM vm-context-offset <+> STR
        SP CTX context-callstack-top-offset <+> LDR FP SP 0 <+> LDR SP SP 16 ADD
        load-stacks ds-1 push-ds
    ] }
    { (start-context) [
        save-context arg1 VM MOV "new_context" native-call* IP1 RETURN MOV
        ds-0 pop-ds ds-1 pop-ds temp PC MOV
        SP SP 16 SUB FP SP 0 <+> STR temp SP 4 <+> STR FP SP MOV save-context
        CTX IP1 MOV CTX VM vm-context-offset <+> STR
        FP CTX context-callstack-top-offset <+> LDR SP FP MOV load-stacks
        ds-1 push-ds temp ds-0 quot-entry-point-offset <+> LDR temp BX
    ] }
    { (start-context-and-delete) [
        save-context arg1 VM MOV "reset_context" native-call*
        FP CTX context-callstack-top-offset <+> LDR SP FP MOV load-stacks
        arg1 pop-ds temp arg1 quot-entry-point-offset <+> LDR temp BX
    ] }
} define-sub-primitives
