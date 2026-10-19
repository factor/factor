! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: assocs bootstrap.image.private compiler.codegen.relocation
compiler.constants compiler.units cpu.alpha.64.assembler
cpu.alpha.64.assembler.registers generic.single.private kernel
kernel.private layouts literals locals locals.backend make math math.bitwise
math.private namespaces sequences slots.private strings.private
threads.private vocabs ;
FROM: cpu.alpha.64.assembler.registers => cache ;
IN: bootstrap.assembler.alpha
8 \ cell set
big-endian off
: save-context ( -- )
    FP CTX context-callstack-top-offset STQ
    DS CTX context-datastack-offset STQ
    RS CTX context-retainstack-offset STQ ;
: load-stacks ( -- )
    DS CTX context-datastack-offset LDQ RS CTX context-retainstack-offset LDQ ;
: prolog ( -- )
    SP SP -32 LDA FP SP 0 STQ RA SP 8 STQ GP SP 16 STQ FP SP MV ;
: epilog ( -- )
    FP SP 0 LDQ RA SP 8 LDQ GP SP 16 LDQ SP SP 32 LDA ;
: native-call ( name -- )
    f PV load-address rel-dlsym TRAMPOLINE JSR ;
: native-call* ( name -- ) native-call load-stacks ;
: pop-ds ( reg -- ) DS 0 LDQ DS DS -8 LDA ;
: push-ds ( reg -- ) DS DS 8 LDA DS 0 STQ ;
: >r ( -- ) ds-0 pop-ds RS RS 8 LDA ds-0 RS 0 STQ ;
: r> ( -- ) ds-0 RS 0 LDQ RS RS -8 LDA ds-0 push-ds ;
: call-word ( -- ) f PV load-address rel-word PV JSR ;
: jump-word ( -- ) f PV load-address rel-word PV JMP ;
: jump-quot ( -- ) temp temp quot-entry-point-offset LDQ temp JMP ;
: call-quot ( -- ) temp temp quot-entry-point-offset LDQ temp JSR ;
: conditional ( test false -- ) jit-conditional ; inline
: tail-address ( -- ) PIC-TAIL 0 BR PIC-TAIL PIC-TAIL 40 LDA ;
[ prolog ] JIT-PROLOG jit-define
[ save-context arg1 VM MV f native-call* ] JIT-PRIMITIVE jit-define
[ tail-address f PV load-address rel-word-pic-tail PV JMP ] JIT-WORD-JUMP jit-define
[ f PV load-address rel-word-pic PV JSR ] JIT-WORD-CALL jit-define
[ ds-0 pop-ds temp \ f type-number LI temp ds-0 temp XOR
  [ temp swap BEQ ] [ jump-word ] conditional jump-word ] JIT-IF jit-define
[ ZERO SAFEPOINT 0 STQ ] JIT-SAFEPOINT jit-define
[ epilog ] JIT-EPILOG jit-define
[ RET ] JIT-RETURN jit-define
[ f ds-0 load-address rel-literal ds-0 push-ds ] JIT-PUSH-LITERAL jit-define
[ >r call-word r> ] JIT-DIP jit-define
[ >r >r call-word r> r> ] JIT-2DIP jit-define
[ >r >r >r call-word r> r> r> ] JIT-3DIP jit-define
[ temp pop-ds temp temp word-entry-point-offset LDQ temp JMP ] JIT-EXECUTE jit-define

! The first six relocation operands match callback_heap's shared ABI.
[ SP SP -272 LDA
  ${ R9 R10 R11 R12 R13 R14 R15 RA GP } [ 8 * SP swap STQ ] each-index
  ${ F2 F3 F4 F5 F6 F7 F8 F9 } [ 8 * 80 + SP swap STT ] each-index
  ${ R16 R17 R18 R19 R20 R21 } [ 8 * 144 + SP swap STQ ] each-index
  ${ F16 F17 F18 F19 F20 F21 } [ 8 * 192 + SP swap STT ] each-index
  0 VM load-address rel-vm CTX VM vm-context-offset LDQ CTX SP 240 STQ
  SAFEPOINT load-address rel-safepoint TRAMPOLINE load-address rel-trampoline
  temp load-address rel-trampoline2 temp load-address rel-inline-cache-miss
  temp load-address rel-megamorphic-cache-hits
  CTX VM vm-spare-context-offset LDQ CTX VM vm-context-offset STQ
  SP CTX context-callstack-save-offset STQ
  SP CTX context-callstack-bottom-offset LDQ SP SP 32 LDA FP ZERO MV load-stacks
  f PV load-address rel-word PV JSR
  SP CTX context-callstack-save-offset LDQ CTX SP 240 LDQ CTX VM vm-context-offset STQ
  ${ F2 F3 F4 F5 F6 F7 F8 F9 } [ 8 * 80 + SP swap LDT ] each-index
  ${ R9 R10 R11 R12 R13 R14 R15 RA GP } [ 8 * SP swap LDQ ] each-index
  SP SP 272 LDA RET ] CALLBACK-STUB jit-define
CALLBACK-STUB special-objects get at dup suffix
CALLBACK-STUB special-objects get set-at

[ f temp load-address rel-untagged obj DS temp ADDQ obj obj 0 LDQ ] PIC-LOAD jit-define
[ type obj tag-mask get ANDI temp1 type MV ] PIC-TAG jit-define
[ type obj tag-mask get ANDI temp tuple type-number LI temp type temp XOR
  [ temp swap BNE ] [ type obj tuple-class-offset LDQ ] conditional ] PIC-TUPLE jit-define
[ f temp load-address rel-untagged temp1 type temp XOR ] PIC-CHECK-TAG jit-define
[ f temp load-address rel-literal temp1 type temp XOR ] PIC-CHECK-TUPLE jit-define
[ [ temp1 swap BNE ] [ jump-word ] conditional ] PIC-HIT jit-define
[ PIC-TAIL RA MV jump-word ] PIC-MISS-JUMP jit-define
[ jump-word ] PIC-MISS-TAIL-JUMP jit-define

! Keep megamorphic lookup correct without assuming caller-saved C registers survive.
! PIC-LOAD has already selected the object at the generic's dispatch index.
[ type obj tag-mask get ANDI type type tag-bits get SLLI
  temp tuple type-number tag-fixnum LI temp type temp XOR
  [ temp swap BNE ] [ type obj tuple-class-offset LDQ ] conditional
  f cache load-address rel-literal
  temp mega-cache-size get 1 - bootstrap-cells LI temp type temp AND
  cache cache temp ADDQ temp cache array-start-offset LDQ temp1 type temp XOR
  [ temp1 swap BNE ] [
      temp load-address rel-megamorphic-cache-hits temp1 temp 0 LDQ
      temp1 temp1 1 ADDQI temp1 temp 0 STQ
      temp cache array-start-offset bootstrap-cell + LDQ
      temp temp word-entry-point-offset LDQ temp JMP
  ] conditional ] MEGA-LOOKUP jit-define

[ arg1 pop-ds temp arg1 MV ] [ call-quot ] [ jump-quot ] \ (call) define-combinator-primitive
[ temp pop-ds temp temp word-entry-point-offset LDQ ]
[ temp JSR ] [ temp JMP ] \ (execute) define-combinator-primitive
[ save-context arg2 VM MV "lazy_jit_compile" native-call*
  temp RETURN MV ] [ call-quot ] [ jump-quot ] \ lazy-jit-compile define-combinator-primitive
: cache-miss ( -- )
    save-context arg1 PIC-TAIL MV arg2 VM MV
    PV load-address rel-inline-cache-miss TRAMPOLINE JSR load-stacks ;
[ PIC-TAIL FP 8 LDQ cache-miss ] [ RETURN JSR ] [ RETURN JMP ]
\ inline-cache-miss define-combinator-primitive
[ cache-miss ] [ RETURN JSR ] [ RETURN JMP ]
\ inline-cache-miss-tail define-combinator-primitive

: jit-signal-handler ( -- )
    SP SP -512 LDA
    32 <iota> [ dup 30 = [ drop ] [ dup int-register boa SP rot 8 * STQ ] if ] each
    32 <iota> [ dup fp-register boa SP rot 8 * 256 + STT ] each
    F0 MF-FPCR F0 SP 240 STT
    save-context PV VM vm-signal-handler-addr-offset LDQ TRAMPOLINE JSR
    F0 SP 240 LDT F0 MT-FPCR
    32 <iota> [ dup fp-register boa SP rot 8 * 256 + LDT ] each
    32 <iota> [ dup 30 = [ drop ] [ dup int-register boa SP rot 8 * LDQ ] if ] each
    SP SP 512 LDA ;
:: compare-result ( compare: ( dst src1 src2 -- ) -- )
    ds-0 DS 0 LDQ ds-1 DS -8 LDQ DS DS -8 LDA
    temp ds-1 ds-0 compare call
    t ds-0 load-address rel-literal ds-1 \ f type-number LI
    ds-1 temp ds-0 CMOVNE ds-1 DS 0 STQ ; inline

{
    { c-to-factor [
      arg2 arg1 MV arg1 VM MV "begin_callback" native-call
      arg1 RETURN MV temp arg1 quot-entry-point-offset LDQ temp JSR
      arg1 VM MV "end_callback" native-call
    ] }
    { unwind-native-frames [
      SP arg2 MV epilog 0 VM load-address rel-vm
      CTX VM vm-context-offset LDQ load-stacks
      SAFEPOINT load-address rel-safepoint TRAMPOLINE load-address rel-trampoline
      ZERO VM vm-fault-flag-offset STQ
      temp arg1 quot-entry-point-offset LDQ temp JMP
    ] }
    { inline-cache-miss-resume [ prolog cache-miss epilog RETURN JMP ] }
    { fpu-state [ F0 MF-FPCR F0 SP 24 STT RETURN SP 24 LDQ
      temp 0x0800000000000000 LI temp SP 24 STQ F0 SP 24 LDT F0 MT-FPCR ] }
    { set-fpu-state [ arg1 SP 24 STQ F0 SP 24 LDT F0 MT-FPCR ] }
    { leaf-signal-handler [
      FP SP 32 STQ RA SP 40 STQ temp SP 32 LDA temp SP 0 STQ FP SP MV
      jit-signal-handler temp SP 8 LDQ FP SP 32 LDQ RA SP 40 LDQ
      SP SP 48 LDA temp JMP
    ] }
    { signal-handler [ FP SP 0 STQ FP SP MV jit-signal-handler
      FP SP 0 LDQ temp SP 8 LDQ SP SP 32 LDA temp JMP ] }
    { drop [ DS DS -8 LDA ] }
    { 2drop [ DS DS -16 LDA ] }
    { 3drop [ DS DS -24 LDA ] }
    { 4drop [ DS DS -32 LDA ] }
    { dup [ ds-0 DS 0 LDQ DS DS 8 LDA ds-0 DS -8 STQ ds-0 DS 0 STQ ] }
    { over [ ds-0 DS 0 LDQ ds-1 DS -8 LDQ DS DS 8 LDA ds-1 DS -16 STQ ds-0 DS -8 STQ ds-1 DS 0 STQ ] }
    { pick [ ds-0 DS 0 LDQ ds-1 DS -8 LDQ ds-2 DS -16 LDQ DS DS 8 LDA ds-2 DS -24 STQ ds-1 DS -16 STQ ds-0 DS -8 STQ ds-2 DS 0 STQ ] }
    { swap [ ds-0 DS 0 LDQ ds-1 DS -8 LDQ ds-0 DS -8 STQ ds-1 DS 0 STQ ] }
    { swapd [ ds-0 DS 0 LDQ ds-1 DS -8 LDQ ds-2 DS -16 LDQ ds-1 DS -16 STQ ds-2 DS -8 STQ ds-0 DS 0 STQ ] }
    { nip [ ds-0 DS 0 LDQ ds-1 DS -8 LDQ DS DS -8 LDA ds-0 DS 0 STQ ] }
    { 2nip [ ds-0 DS 0 LDQ ds-1 DS -8 LDQ ds-2 DS -16 LDQ DS DS -16 LDA ds-0 DS 0 STQ ] }
    { 2dup [ ds-0 DS 0 LDQ ds-1 DS -8 LDQ DS DS 16 LDA ds-1 DS -24 STQ ds-0 DS -16 STQ ds-1 DS -8 STQ ds-0 DS 0 STQ ] }
    { dupd [ ds-0 DS 0 LDQ ds-1 DS -8 LDQ DS DS 8 LDA ds-1 DS -16 STQ ds-1 DS -8 STQ ds-0 DS 0 STQ ] }
    { 3dup [ ds-0 DS 0 LDQ ds-1 DS -8 LDQ ds-2 DS -16 LDQ DS DS 24 LDA ds-2 DS -40 STQ ds-1 DS -32 STQ ds-0 DS -24 STQ ds-2 DS -16 STQ ds-1 DS -8 STQ ds-0 DS 0 STQ ] }
    { 4dup [ ds-0 DS 0 LDQ ds-1 DS -8 LDQ ds-2 DS -16 LDQ ds-3 DS -24 LDQ DS DS 32 LDA ds-3 DS -56 STQ ds-2 DS -48 STQ ds-1 DS -40 STQ ds-0 DS -32 STQ ds-3 DS -24 STQ ds-2 DS -16 STQ ds-1 DS -8 STQ ds-0 DS 0 STQ ] }
    { rot [ ds-0 DS 0 LDQ ds-1 DS -8 LDQ ds-2 DS -16 LDQ ds-1 DS -16 STQ ds-0 DS -8 STQ ds-2 DS 0 STQ ] }
    { -rot [ ds-0 DS 0 LDQ ds-1 DS -8 LDQ ds-2 DS -16 LDQ ds-0 DS -16 STQ ds-2 DS -8 STQ ds-1 DS 0 STQ ] }
    { eq? [ [ CMPEQ ] compare-result ] }
    { fixnum< [ [ CMPLT ] compare-result ] }
    { fixnum<= [ [ CMPLE ] compare-result ] }
    { fixnum> [ [ swap CMPLT ] compare-result ] }
    { fixnum>= [ [ swap CMPLE ] compare-result ] }
    { tag [ ds-0 DS 0 LDQ ds-0 ds-0 tag-mask get ANDI
      ds-0 ds-0 tag-bits get SLLI ds-0 DS 0 STQ ] }
    { drop-locals [ ds-0 pop-ds ds-0 ds-0 tag-bits get 3 - SRAI RS RS ds-0 SUBQ ] }
    { get-local [ ds-0 DS 0 LDQ ds-0 ds-0 tag-bits get 3 - SRAI
      temp RS ds-0 ADDQ ds-0 temp 0 LDQ ds-0 DS 0 STQ ] }
    { load-local [ >r ] }
    { both-fixnums? [ ds-0 DS 0 LDQ ds-1 DS -8 LDQ DS DS -8 LDA
      temp ds-0 ds-1 BIS temp temp tag-mask get ANDI
      ds-0 1 tag-fixnum LI ds-1 \ f type-number LI
      ds-1 temp ds-0 CMOVEQ ds-1 DS 0 STQ ] }
    { fixnum+fast [ ds-0 DS 0 LDQ ds-1 DS -8 LDQ DS DS -8 LDA ds-0 ds-1 ds-0 ADDQ ds-0 DS 0 STQ ] }
    { fixnum-fast [ ds-0 DS 0 LDQ ds-1 DS -8 LDQ DS DS -8 LDA ds-0 ds-1 ds-0 SUBQ ds-0 DS 0 STQ ] }
    { fixnum-bitand [ ds-0 DS 0 LDQ ds-1 DS -8 LDQ DS DS -8 LDA ds-0 ds-1 ds-0 AND ds-0 DS 0 STQ ] }
    { fixnum-bitor [ ds-0 DS 0 LDQ ds-1 DS -8 LDQ DS DS -8 LDA ds-0 ds-1 ds-0 BIS ds-0 DS 0 STQ ] }
    { fixnum-bitxor [ ds-0 DS 0 LDQ ds-1 DS -8 LDQ DS DS -8 LDA ds-0 ds-1 ds-0 XOR ds-0 DS 0 STQ ] }
    { fixnum-bitnot [ ds-0 DS 0 LDQ ds-0 ds-0 NOT
      ds-0 ds-0 tag-mask get BICI ds-0 DS 0 STQ ] }
    { fixnum*fast [ ds-0 DS 0 LDQ ds-1 DS -8 LDQ DS DS -8 LDA
      ds-0 ds-0 tag-bits get SRAI ds-0 ds-1 ds-0 MULQ ds-0 DS 0 STQ ] }
    { fixnum+ [ save-context arg1 VM MV "alpha_fixnum_add" native-call* ] }
    { fixnum- [ save-context arg1 VM MV "alpha_fixnum_subtract" native-call* ] }
    { fixnum* [ save-context arg1 VM MV "alpha_fixnum_multiply" native-call* ] }
    { fixnum-mod [ save-context arg1 VM MV "alpha_fixnum_mod" native-call* ] }
    { fixnum/i-fast [ save-context arg1 VM MV "alpha_fixnum_divide" native-call* ] }
    { fixnum/mod-fast [ save-context arg1 VM MV "alpha_fixnum_divmod" native-call* ] }
    { fixnum-shift-fast [ ds-0 DS 0 LDQ ds-1 DS -8 LDQ DS DS -8 LDA
      ds-0 ds-0 tag-bits get SRAI
      [ ds-0 swap BLT ] [ ds-1 ds-1 ds-0 SLL ] conditional
      [ ds-0 swap BGE ] [ ds-0 ds-0 NEG ds-1 ds-1 ds-0 SRA
        ds-1 ds-1 tag-mask get BICI ] conditional ds-1 DS 0 STQ ] }
    { slot [ ds-0 DS 0 LDQ ds-1 DS -8 LDQ DS DS -8 LDA
      ds-0 ds-0 tag-bits get 3 - SRAI ds-1 ds-1 tag-mask get BICI
      temp ds-1 ds-0 ADDQ ds-0 temp 0 LDQ ds-0 DS 0 STQ ] }
    { string-nth-fast [ ds-0 DS 0 LDQ ds-1 DS -8 LDQ DS DS -8 LDA
      ds-1 ds-1 tag-bits get SRAI temp ds-0 ds-1 ADDQ
      ds-0 temp string-offset LDBU ds-0 ds-0 tag-bits get SLLI ds-0 DS 0 STQ ] }
    { set-callstack [
      ds-0 pop-ds temp1 ds-0 callstack-top-offset LDA
      temp3 ds-0 callstack-length-offset LDQ temp3 temp3 tag-bits get SRAI
      ds-0 CTX context-callstack-bottom-offset LDQ SP ds-0 temp3 SUBQ temp2 SP MV
      ! Restore inline: a C helper could overwrite its own active stack.
      temp3 52 BEQ
      ds-1 temp1 0 LDQ ds-1 temp2 0 STQ
      temp1 temp1 8 LDA temp2 temp2 8 LDA temp3 temp3 -8 LDA temp3 -24 BNE
      temp2 SP MV
      ds-1 temp2 0 LDQ ds-1 temp2 ds-1 ADDQ ds-1 temp2 0 STQ
      temp2 ds-1 MV temp3 temp2 ds-0 CMPULT temp3 -24 BNE
      epilog RET
    ] }
    { (set-context) [
      ds-0 pop-ds ds-0 ds-0 alien-offset LDQ ds-1 pop-ds temp 0 BR
      SP SP -32 LDA FP SP 0 STQ temp SP 8 STQ GP SP 16 STQ FP SP MV save-context
      CTX ds-0 MV CTX VM vm-context-offset STQ
      SP CTX context-callstack-top-offset LDQ FP SP 0 LDQ GP SP 16 LDQ SP SP 32 LDA
      load-stacks ds-1 push-ds
    ] }
    { (set-context-and-delete) [
      save-context arg1 VM MV "delete_context" native-call
      ds-0 pop-ds ds-0 ds-0 alien-offset LDQ ds-1 pop-ds
      CTX ds-0 MV CTX VM vm-context-offset STQ
      SP CTX context-callstack-top-offset LDQ FP SP 0 LDQ GP SP 16 LDQ SP SP 32 LDA
      load-stacks ds-1 push-ds
    ] }
    { (start-context) [
      save-context arg1 VM MV "new_context" native-call*
      ds-0 pop-ds ds-1 pop-ds temp 0 BR
      SP SP -32 LDA FP SP 0 STQ temp SP 8 STQ GP SP 16 STQ FP SP MV save-context
      CTX RETURN MV CTX VM vm-context-offset STQ
      FP CTX context-callstack-top-offset LDQ SP FP MV load-stacks
      ds-1 push-ds arg1 ds-0 MV temp arg1 quot-entry-point-offset LDQ temp JMP
    ] }
    { (start-context-and-delete) [
      save-context arg1 VM MV "reset_context" native-call*
      FP CTX context-callstack-top-offset LDQ SP FP MV load-stacks
      arg1 pop-ds temp arg1 quot-entry-point-offset LDQ temp JMP
    ] }
} define-sub-primitives
[ "bootstrap.assembler.alpha" forget-vocab ] with-compilation-unit
