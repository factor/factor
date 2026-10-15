! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: assocs bootstrap.image.private compiler.codegen.relocation
compiler.constants compiler.units cpu.vax.assembler cpu.vax.assembler.registers endian
generic.single.private kernel kernel.private layouts locals locals.backend
make math math.bitwise math.private namespaces sequences slots.private
strings.private threads.private vocabs ;
FROM: bootstrap.image.private => big-endian ;
IN: bootstrap.assembler.vax

4 \ cell set
big-endian off

: prolog ( -- ) SP SP -12 add-offset ;
: epilog ( -- ) SP SP 12 add-offset ;
: save-context ( -- )
    temp SP -4 add-offset temp CTX context-callstack-top-offset SW
    DS CTX context-datastack-offset SW
    RS CTX context-retainstack-offset SW ;
: load-stacks ( -- )
    DS CTX context-datastack-offset LW
    RS CTX context-retainstack-offset LW ;
: load-context ( -- ) CTX VM vm-context-offset LW ;
: load-vm ( -- ) literal-prefix 0 rc-absolute-cell rel-vm VM R % ;
: vm-arg ( offset -- ) VM SP rot SW ;
: pop-ds ( reg -- ) DS 0 LW DS DS -4 add-offset ;
: push-ds ( reg -- ) DS DS 4 add-offset DS 0 SW ;
: >r ( -- ) temp pop-ds RS RS 4 add-offset temp RS 0 SW ;
: r> ( -- ) temp RS 0 LW RS RS -4 add-offset temp push-ds ;
: jump-word ( -- ) 0 JMP f rc-absolute-cell rel-word ;
: call-word ( -- ) 0 JSB f rc-absolute-cell rel-word ;
! Lazy compilation receives the quotation in temp, not its entry point.
: jump-quot ( -- ) temp2 temp quot-entry-point-offset LW temp2 INDIRECT JMP* ;
: call-quot ( -- ) temp2 temp quot-entry-point-offset LW temp2 INDIRECT JSB* ;
: jump-return ( -- ) 0 INDIRECT JMP* ;
: call-return ( -- ) 0 INDIRECT JSB* ;
: conditional ( test false -- ) jit-conditional ; inline

! The prefix is followed by a seven-byte native target load and a six-byte
! JSB into pinned native text. MOVAL anchors the Factor continuation after JSB.
:: call-body ( bytes -- code )
    [ SP CTX context-callstack-top-offset SW
      DS CTX context-datastack-offset SW
      RS CTX context-retainstack-offset SW
      temp SP 4 add-offset
      bytes 4 /i <iota> <reversed>
      [ 4 * temp swap MEM PUSHL ] each
      bytes 4 /i immediate-operand PUSHL
    ] B{ } make ;
:: call-prefix ( bytes -- )
    bytes call-body :> code
    15 code length 14 + MEM SP PREDEC MOVAL code % ;
: call-bridge ( -- )
    0 JSB "vax_native_call_bridge" f rc-absolute-cell rel-dlsym ;
:: native-call ( name bytes -- )
    bytes call-prefix
    literal-prefix name f rc-absolute-cell rel-dlsym temp2 R %
    call-bridge ;
: native-call* ( name bytes -- ) native-call load-stacks ;
: native-leaf-call ( name count -- )
    immediate-operand 0 ABS CALLS f rc-absolute-cell rel-dlsym ;
: native-mask ( mask -- ) 2 >le % ;

[ prolog ] JIT-PROLOG jit-define
[ 0 vm-arg f 4 native-call* ] 2 make-jit-with-parameters
JIT-PRIMITIVE special-objects get set-at
[ literal-prefix 7 rc-absolute-cell rel-here temp2 R %
  0 JMP f rc-absolute-cell rel-word-pic-tail ] JIT-WORD-JUMP jit-define
[ 0 JSB f rc-absolute-cell rel-word-pic ] JIT-WORD-CALL jit-define
[ temp pop-ds temp R \ f type-number immediate-operand CMPL
  [ BEQL ] [ jump-word ] conditional jump-word ] JIT-IF jit-define
[ 0 ABS CLRL rc-absolute-cell rel-safepoint ] JIT-SAFEPOINT jit-define
[ epilog ] JIT-EPILOG jit-define
[ RSB ] JIT-RETURN jit-define
[ literal-prefix f rc-absolute-cell rel-literal temp R %
  temp push-ds ] JIT-PUSH-LITERAL jit-define
[ >r call-word r> ] JIT-DIP jit-define
[ >r >r call-word r> r> ] JIT-2DIP jit-define
[ >r >r >r call-word r> r> r> ] JIT-3DIP jit-define
[ temp pop-ds temp temp word-entry-point-offset LW
  temp INDIRECT JMP* ] JIT-EXECUTE jit-define

! Native AP remains the incoming argument list throughout the callback.
! Saved native SP names old-context, old-FP-state, hidden-result-pointer.
[ 0x0ffc native-mask
  1 R PUSHL "vax_get_fpu_state" 0 native-leaf-call 0 R PUSHL
  load-vm load-context CTX R PUSHL
  CTX VM vm-spare-context-offset LW CTX VM vm-context-offset SW
  SP CTX context-callstack-save-offset SW
  SP CTX context-callstack-bottom-offset LW SP SP 4 add-offset load-stacks
  0 LITERAL PUSHL "vax_set_fpu_state" 1 native-leaf-call
  call-word
  load-vm load-context SP CTX context-callstack-save-offset LW
  SP POSTINC CTX R MOVL CTX VM vm-context-offset SW
  3 LITERAL PUSHR SP 8 MEM PUSHL
  "vax_set_fpu_state" 1 native-leaf-call 3 LITERAL POPR
  SP SP 8 add-offset RET
] CALLBACK-STUB jit-define
CALLBACK-STUB special-objects get at dup suffix
CALLBACK-STUB special-objects get set-at

! R1 preserves the tail call-site while temp2 carries the dispatch class.
: pic-load ( -- )
    1 temp2 MV
    0xd0 , 0xc6 , 0 2 >le % f rc-absolute-2 rel-untagged temp2 R % ;
[ pic-load ] PIC-LOAD jit-define
[ tag-mask get bitnot 32 bits immediate-operand
  temp2 R temp2 R BICL3 ] PIC-TAG jit-define
[ temp temp2 MV tag-mask get bitnot 32 bits immediate-operand
  temp2 R temp2 R BICL3
  temp2 R tuple type-number immediate-operand CMPL
  [ BNEQ ] [ temp2 temp tuple-class-offset LW ] conditional ] PIC-TUPLE jit-define
[ temp2 R 0 IMM.L CMPL f rc-absolute-cell rel-untagged ] PIC-CHECK-TAG jit-define
[ temp2 R 0 IMM.L CMPL f rc-absolute-cell rel-literal ] PIC-CHECK-TUPLE jit-define
[ [ BNEQ ] [ jump-word ] conditional ] PIC-HIT jit-define
[ temp2 SP 0 LW jump-word ] PIC-MISS-JUMP jit-define
[ temp2 1 MV jump-word ] PIC-MISS-TAIL-JUMP jit-define
! PIC-LOAD has already loaded temp2 and consumed the index literal.
[ temp temp2 MV
  tag-mask get bitnot 32 bits immediate-operand temp2 R temp2 R BICL3
  tag-bits get immediate-operand temp2 R temp2 R ASHL
  temp2 R tuple type-number tag-fixnum immediate-operand CMPL
  [ BNEQ ] [ temp2 temp tuple-class-offset LW ] conditional
  literal-prefix f rc-absolute-cell rel-literal 0 R %
  mega-cache-size get 1 - bootstrap-cells bitnot 32 bits immediate-operand
  temp2 R temp R BICL3 temp R 0 R ADDL2
  temp 0 array-start-offset LW temp R temp2 R CMPL
  [ BNEQ ] [
    literal-prefix rc-absolute-cell rel-megamorphic-cache-hits 1 R %
    1 INDIRECT INCL
    temp 0 array-start-offset bootstrap-cell + LW
    temp temp word-entry-point-offset LW temp INDIRECT JMP*
  ] conditional ] MEGA-LOOKUP jit-define

[ temp pop-ds ] [ call-quot ] [ jump-quot ] \ (call) define-combinator-primitive
[ temp pop-ds temp temp word-entry-point-offset LW ]
[ temp INDIRECT JSB* ] [ temp INDIRECT JMP* ]
\ (execute) define-combinator-primitive
[ temp SP 0 SW 4 vm-arg "lazy_jit_compile" 8 native-call* temp 0 MV ]
[ call-quot ] [ jump-quot ] \ lazy-jit-compile define-combinator-primitive
:: cache-miss ( -- )
    temp2 SP 0 SW 4 vm-arg
    8 call-prefix
    literal-prefix rc-absolute-cell rel-inline-cache-miss temp2 R %
    call-bridge load-stacks ;
[ temp2 SP 12 LW cache-miss ] [ call-return ] [ jump-return ]
\ inline-cache-miss define-combinator-primitive
[ cache-miss ] [ call-return ] [ jump-return ]
\ inline-cache-miss-tail define-combinator-primitive

! PUSHR saves R0..R11/AP/FP. MOVAL adjusts SP without changing NZVC.
: signal-prolog ( -- )
    SP PREDEC MOVPSL 0x3fff IMM.W PUSHR load-vm load-context ;
: signal-epilog ( -- )
    0x3fff IMM.W POPR SP 4 MEM SP R MOVAL
    15 LITERAL BICPSW SP -4 MEM BISPSW ;
: signal-call ( -- )
    save-context temp VM vm-signal-handler-addr-offset LW
    0 LITERAL temp INDIRECT CALLS ;
: leaf-signal-epilog ( -- )
    0 SP 60 LW 0 SP 72 SW 0x3fff IMM.W POPR
    SP 16 MEM SP R MOVAL 15 LITERAL BICPSW SP -16 MEM BISPSW ;

:: boolean-compare ( inverse -- )
    temp DS 0 LW temp2 DS -4 LW DS DS -4 add-offset
    0 \ f type-number LI literal-prefix t rc-absolute-cell rel-literal 1 R %
    temp2 R temp R CMPL
    [ inverse branch-byte ] [ 1 R 0 R MOVL ] conditional 0 DS 0 SW ;
: binary-inputs ( -- ) temp DS 0 LW temp2 DS -4 LW DS DS -4 add-offset ;
: binary-result ( -- ) temp2 DS 0 SW ;
:: copy-callstack ( -- )
    building get length :> start
    1 temp 0 LW 1 0 0 SW
    temp temp 4 add-offset 0 0 4 add-offset
    4 immediate-operand temp2 R SUBL2
    start building get length - 2 - BNEQ ;
: restore-callstack ( -- )
    temp pop-ds temp2 temp callstack-length-offset LW
    tag-bits get neg IMM.B temp2 R temp2 R ASHL
    temp temp callstack-top-offset add-offset
    SP CTX context-callstack-bottom-offset LW
    temp2 R SP R SP R SUBL3 0 SP MV
    ! The copied stack already starts at its saved resume PC.
    temp2 R TSTL [ BEQL ] [ copy-callstack ] conditional RSB ;
:: checked-binary ( operation helper -- )
    binary-inputs temp2 SP 0 SW temp SP 4 SW 8 vm-arg
    operation call( -- )
    [ BVC ] [ helper 12 native-call* temp2 DS 0 LW ] conditional
    binary-result ;
: check-divisor ( -- )
    temp R TSTL [ BNEQ ] [
        0 vm-arg "divide_by_zero" 4 native-call
    ] conditional ;
: switch-context ( -- )
    0 JSB 0 rc-absolute-cell rel-here
    CTX temp2 MV CTX VM vm-context-offset SW
    SP CTX context-callstack-top-offset LW load-stacks ;
: set-context ( -- )
    temp pop-ds temp2 temp alien-offset LW 1 pop-ds
    save-context switch-context SP SP 4 add-offset 1 push-ds ;
: start-context ( -- )
    0 vm-arg "new_context" 4 native-call* temp2 0 MV
    temp pop-ds 1 pop-ds save-context switch-context
    1 push-ds SP SP 4 add-offset 0 LITERAL PUSHL jump-quot ;
: quotient ( -- ) temp R temp2 R 0 R DIVL3 ;
: tagged-quotient ( -- ) tag-bits get immediate-operand 0 R temp2 R ASHL ;
: remainder ( -- )
    temp R 0 R 1 R MULL3 1 R temp2 R temp2 R SUBL3 ;

{
    { c-to-factor [ temp 12 4 LW temp SP 4 SW 0 vm-arg
        "begin_callback" 8 native-call* temp 0 MV call-quot
        0 vm-arg "end_callback" 4 native-call ] }
    { unwind-native-frames [ 0 native-mask temp 12 4 LW temp2 12 8 LW
        load-vm load-context load-stacks 0 LITERAL VM vm-fault-flag-offset MEM MOVL
        SP temp2 MV jump-quot ] }
    { inline-cache-miss-resume [ prolog cache-miss epilog jump-return ] }
    { fpu-state [ "vax_get_fpu_state" 0 native-leaf-call ] }
    { set-fpu-state [ SP 16 MEM PUSHL "vax_set_fpu_state" 1 native-leaf-call ] }
    { leaf-signal-handler [ signal-prolog signal-call leaf-signal-epilog RSB ] }
    { signal-handler [ signal-prolog signal-call signal-epilog RSB ] }
    { drop [ DS DS -4 add-offset ] }
    { 2drop [ DS DS -8 add-offset ] }
    { 3drop [ DS DS -12 add-offset ] }
    { 4drop [ DS DS -16 add-offset ] }
    { dup [ temp DS 0 LW temp push-ds ] }
    { over [ temp DS -4 LW temp push-ds ] }
    { pick [ temp DS -8 LW temp push-ds ] }
    { swap [ temp DS 0 LW temp2 DS -4 LW temp DS -4 SW temp2 DS 0 SW ] }
    { swapd [ temp DS -4 LW temp2 DS -8 LW temp DS -8 SW temp2 DS -4 SW ] }
    { nip [ temp pop-ds temp DS 0 SW ] }
    { 2nip [ temp pop-ds DS DS -4 add-offset temp DS 0 SW ] }
    { 2dup [ temp DS -4 LW temp2 DS 0 LW temp push-ds temp2 push-ds ] }
    { dupd [ temp DS 0 LW temp2 DS -4 LW temp2 DS 0 SW temp push-ds ] }
    { 3dup [ temp DS -8 LW temp push-ds temp DS -8 LW temp push-ds
        temp DS -8 LW temp push-ds ] }
    { 4dup [ temp DS -12 LW temp push-ds temp DS -12 LW temp push-ds
        temp DS -12 LW temp push-ds temp DS -12 LW temp push-ds ] }
    { rot [ temp DS -8 LW temp2 DS -4 LW temp2 DS -8 SW
        temp2 DS 0 LW temp2 DS -4 SW temp DS 0 SW ] }
    { -rot [ temp DS 0 LW temp2 DS -4 LW temp2 DS 0 SW
        temp2 DS -8 LW temp2 DS -4 SW temp DS -8 SW ] }
    { set-callstack [ restore-callstack ] }
    { both-fixnums? [ binary-inputs temp R temp2 R temp2 R BISL3
        tag-mask get bitnot 32 bits immediate-operand temp2 R temp2 R BICL3
        0 \ f type-number LI 1 1 tag-fixnum LI temp2 R TSTL
        [ BNEQ ] [ 1 R 0 R MOVL ] conditional 0 DS 0 SW ] }
    { tag [ tag-mask get bitnot 32 bits immediate-operand DS 0 MEM temp R BICL3
        tag-bits get immediate-operand temp R temp R ASHL temp DS 0 SW ] }
    { (set-context) [ set-context ] }
    { (set-context-and-delete) [ 0 vm-arg "delete_context" 4 native-call set-context ] }
    { (start-context) [ start-context ] }
    { (start-context-and-delete) [ 0 vm-arg "reset_context" 4 native-call*
        SP CTX context-callstack-top-offset LW load-stacks
        temp pop-ds SP SP 4 add-offset 0 LITERAL PUSHL jump-quot ] }
    { fixnum+ [ [ temp R temp2 R ADDL2 ] "overflow_fixnum_add" checked-binary ] }
    { fixnum- [ [ temp R temp2 R SUBL2 ] "overflow_fixnum_subtract" checked-binary ] }
    { fixnum* [ binary-inputs
        tag-bits get neg IMM.B temp R temp R ASHL temp SP 4 SW
        tag-bits get neg IMM.B temp2 R 0 R ASHL 0 SP 0 SW 8 vm-arg
        temp R temp2 R temp2 R MULL3
        [ BVC ] [ "overflow_fixnum_multiply" 12 native-call* temp2 DS 0 LW ] conditional
        binary-result ] }
    { fixnum+fast [ binary-inputs temp R temp2 R ADDL2 binary-result ] }
    { fixnum-fast [ binary-inputs temp R temp2 R SUBL2 binary-result ] }
    { fixnum-bitor [ binary-inputs temp R temp2 R temp2 R BISL3 binary-result ] }
    { fixnum-bitxor [ binary-inputs temp R temp2 R temp2 R XORL3 binary-result ] }
    { fixnum-bitand [ binary-inputs temp R temp R MCOML
        temp R temp2 R temp2 R BICL3 binary-result ] }
    { fixnum-bitnot [ tag-mask get bitnot 32 bits immediate-operand
        DS 0 MEM DS 0 MEM XORL3 ] }
    { fixnum*fast [ binary-inputs tag-bits get neg IMM.B
        temp R temp R ASHL temp R temp2 R temp2 R MULL3 binary-result ] }
    { fixnum-shift-fast [ binary-inputs
        tag-bits get neg IMM.B temp R temp R ASHL
        temp R -32 immediate-operand CMPL
        [ BGEQ ] [ temp -32 LI ] conditional
        temp R 32 immediate-operand CMPL
        [ BLSS ] [ temp 32 LI ] conditional
        temp R temp2 R temp2 R ASHL
        tag-mask get immediate-operand temp2 R temp2 R BICL3 binary-result ] }
    { drop-locals [ temp pop-ds tag-bits get 2 - neg IMM.B
        temp R temp R ASHL temp R RS R RS R SUBL3 ] }
    { get-local [ temp DS 0 LW tag-bits get 2 - neg IMM.B
        temp R temp R ASHL temp R RS R temp R ADDL3
        temp temp 0 LW temp DS 0 SW ] }
    { load-local [ >r ] }
    { slot [ binary-inputs tag-bits get 2 - neg IMM.B
        temp R temp R ASHL tag-mask get immediate-operand
        temp2 R temp2 R BICL3 temp R temp2 R temp2 R ADDL3
        temp2 temp2 0 LW binary-result ] }
    { string-nth-fast [ binary-inputs tag-bits get neg IMM.B
        temp2 R temp2 R ASHL temp2 R temp R temp R ADDL3
        temp string-offset MEM temp2 R MOVZBL
        tag-bits get immediate-operand temp2 R temp2 R ASHL binary-result ] }
    { fixnum-mod [ binary-inputs check-divisor quotient remainder binary-result ] }
    { fixnum/i-fast [ binary-inputs check-divisor quotient tagged-quotient binary-result ] }
    { fixnum/mod-fast [ temp DS 0 LW temp2 DS -4 LW check-divisor quotient
        remainder temp2 DS 0 SW tagged-quotient temp2 DS -4 SW ] }
    { eq? [ 0x12 boolean-compare ] }
    { fixnum< [ 0x18 boolean-compare ] }
    { fixnum<= [ 0x14 boolean-compare ] }
    { fixnum> [ 0x15 boolean-compare ] }
    { fixnum>= [ 0x19 boolean-compare ] }
} define-sub-primitives

[ "bootstrap.assembler.vax" forget-vocab ] with-compilation-unit
