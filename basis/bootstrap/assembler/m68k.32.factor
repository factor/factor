! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: assocs bootstrap.image.private compiler.codegen.relocation
compiler.constants compiler.units cpu.m68k.assembler generic.single.private
kernel kernel.private layouts locals locals.backend make math math.bitwise
math.private namespaces sequences slots.private strings.private
threads.private vocabs ;
FROM: cpu.m68k.assembler => emit-word ;
IN: bootstrap.assembler.m68k

4 \ cell set
big-endian on

! D4/D5,A0/A1 are scratches. D6 carries a PIC tail site's address.
! A2/A3 are the Factor stacks, A4 the VM, A5 its active context.
: prolog ( -- ) 7 -12 7 LEA ;
: epilog ( -- ) 7 12 7 LEA ;
: save-context ( -- )
    7 -4 0 LEA 0 5 context-callstack-top-offset STOREA.L
    2 5 context-datastack-offset STOREA.L
    3 5 context-retainstack-offset STOREA.L ;
: load-stacks ( -- )
    5 context-datastack-offset 2 LOADA.L
    5 context-retainstack-offset 3 LOADA.L ;
: load-context ( -- ) 4 vm-context-offset 5 LOADA.L ;
: load-vm ( -- ) 0 4 MOVEAI.L 0 rc-absolute-cell rel-vm ;
: native-call ( name -- ) 0 JSR f rc-absolute-cell rel-dlsym ;
: native-call* ( name -- ) native-call load-stacks ;
: vm-arg ( offset -- ) 4 7 rot STOREA.L ;
: pop-ds ( dn -- ) 2 0 rot LOAD.L 2 -4 2 LEA ;
: push-ds ( dn -- ) 2 4 2 LEA 2 0 STORE.L ;
: >r ( -- ) 4 pop-ds 3 4 3 LEA 4 3 0 STORE.L ;
: r> ( -- ) 3 0 4 LOAD.L 3 -4 3 LEA 4 push-ds ;
: jump-word ( -- ) 0 JMP f rc-absolute-cell rel-word ;
: call-word ( -- ) 0 JSR f rc-absolute-cell rel-word ;
: jump-quot ( -- ) 4 0 MOVEA.L 0 quot-entry-point-offset 0 LOADA.L 0 JMPA ;
: call-quot ( -- ) 4 0 MOVEA.L 0 quot-entry-point-offset 0 LOADA.L 0 JSRA ;
: jump-return ( -- ) 0 0 MOVEA.L 0 JMPA ;
: call-return ( -- ) 0 0 MOVEA.L 0 JSRA ;
! A word branch displacement is relative to its extension word, at PC+2.
: conditional ( test false -- ) [ '[ 2 + @ ] ] dip jit-conditional ; inline

[ prolog ] JIT-PROLOG jit-define
[ save-context 0 vm-arg f native-call* ] JIT-PRIMITIVE jit-define
[ 0 6 MOVEI.L 6 rc-absolute-cell rel-here
  0 JMP f rc-absolute-cell rel-word-pic-tail ] JIT-WORD-JUMP jit-define
[ 0 JSR f rc-absolute-cell rel-word-pic ] JIT-WORD-CALL jit-define
[ 4 pop-ds \ f type-number 4 CMPI.L
  [ BEQ ] [ jump-word ] conditional jump-word ] JIT-IF jit-define
[ 0 0 MOVEAI.L rc-absolute-cell rel-safepoint 4 0 0 STORE.L ] JIT-SAFEPOINT jit-define
[ epilog ] JIT-EPILOG jit-define
[ RTS ] JIT-RETURN jit-define
[ 0 4 MOVEI.L f rc-absolute-cell rel-literal 4 push-ds ] JIT-PUSH-LITERAL jit-define
[ >r call-word r> ] JIT-DIP jit-define
[ >r >r call-word r> r> ] JIT-2DIP jit-define
[ >r >r >r call-word r> r> r> ] JIT-3DIP jit-define
[ 4 pop-ds 4 0 MOVEA.L 0 word-entry-point-offset 0 LOADA.L 0 JMPA ] JIT-EXECUTE jit-define

[ ! Native arguments remain reachable through A6 throughout a callback.
  ! Aggregate result pointers: GNU A1 at A6-4, NetBSD A0 at A6-8.
  1 PUSHA.L 0 PUSHA.L 0x7cfc MOVEM-PUSH 7 52 6 LEA
  0xf227 emit-word 0xe0fc emit-word FPU-CONTROL-PUSH
  load-vm load-context 5 PUSHA.L
  4 vm-spare-context-offset 5 LOADA.L 5 4 vm-context-offset STOREA.L
  7 5 context-callstack-save-offset STOREA.L
  5 context-callstack-bottom-offset 7 LOADA.L 7 4 7 LEA load-stacks
  0x80 4 MOVEI.L 4 SET-FPCR
  0 JSR f rc-absolute-cell rel-word
  load-vm load-context 5 context-callstack-save-offset 7 LOADA.L
  5 POPA.L 5 4 vm-context-offset STOREA.L
  FPU-CONTROL-POP 0xf21f emit-word 0xd03f emit-word
  0x7cfc MOVEM-POP 7 8 7 LEA RTS ] CALLBACK-STUB jit-define
! Stack-only GNU ABI varargs use the same stub.
CALLBACK-STUB special-objects get at dup suffix
CALLBACK-STUB special-objects get set-at

[ 2 0 5 LOAD.L f rc-absolute-2 rel-untagged ] PIC-LOAD jit-define
[ tag-mask get 5 ANDI.L ] PIC-TAG jit-define
[ 5 4 MOVE.L tag-mask get 5 ANDI.L tuple type-number 5 CMPI.L
  [ BNE ] [ 4 0 MOVEA.L 0 tuple-class-offset 5 LOAD.L ] conditional ] PIC-TUPLE jit-define
[ 0 5 CMPI.L f rc-absolute-cell rel-untagged ] PIC-CHECK-TAG jit-define
[ 0 5 CMPI.L f rc-absolute-cell rel-literal ] PIC-CHECK-TUPLE jit-define
[ [ BNE ] [ jump-word ] conditional ] PIC-HIT jit-define
[ 7 0 6 LOAD.L jump-word ] PIC-MISS-JUMP jit-define
[ jump-word ] PIC-MISS-TAIL-JUMP jit-define
! PIC-LOAD already selected the receiver at the generic dispatch index.
[ 5 4 MOVE.L tag-mask get 5 ANDI.L
  tag-bits get 5 LSL.L tuple type-number tag-fixnum 5 CMPI.L
  [ BNE ] [ 4 0 MOVEA.L 0 tuple-class-offset 5 LOAD.L ] conditional
  0 0 MOVEAI.L f rc-absolute-cell rel-literal
  ! mega-cache-size counts cells, with two cells per class/method pair.
  5 4 MOVE.L 1 4 LSR.L mega-cache-size get 2 /i 1 - 2 * bootstrap-cells 4 ANDI.L 4 0 ADDA.L
  0 array-start-offset 4 LOAD.L 4 5 CMP.L
  [ BNE ] [
      0 1 MOVEAI.L rc-absolute-cell rel-megamorphic-cache-hits
      1 0 4 LOAD.L 1 4 ADDI.L 4 1 0 STORE.L
      0 array-start-offset bootstrap-cell + 0 LOADA.L
      0 word-entry-point-offset 0 LOADA.L 0 JMPA
  ] conditional ] MEGA-LOOKUP jit-define

[ 4 pop-ds ] [ call-quot ] [ jump-quot ] \ (call) define-combinator-primitive
[ 4 pop-ds 4 0 MOVEA.L 0 word-entry-point-offset 0 LOADA.L ]
[ 0 JSRA ] [ 0 JMPA ] \ (execute) define-combinator-primitive
[ save-context 4 7 0 STORE.L 4 vm-arg "lazy_jit_compile" native-call*
  0 4 MOVE.L ] [ call-quot ] [ jump-quot ] \ lazy-jit-compile define-combinator-primitive
: cache-miss ( -- )
    save-context 6 7 0 STORE.L 4 vm-arg
    0 JSR rc-absolute-cell rel-inline-cache-miss load-stacks ;
[ 7 12 6 LOAD.L cache-miss ] [ call-return ] [ jump-return ]
\ inline-cache-miss define-combinator-primitive
[ cache-miss ] [ call-return ] [ jump-return ]
\ inline-cache-miss-tail define-combinator-primitive

! Includes injected return address: 4+60+96+12+2+2 = 176 bytes.
: signal-prolog ( -- )
    0x42e7 emit-word 0x7fff MOVEM-PUSH FPU-PUSH FPU-CONTROL-PUSH
    7 -2 7 LEA load-vm load-context ;
: signal-epilog ( -- )
    7 2 7 LEA FPU-CONTROL-POP FPU-POP 0x7fff MOVEM-POP 0x44df emit-word ;
: signal-call ( -- )
    save-context 4 vm-signal-handler-addr-offset 0 LOADA.L 0 JSRA ;
:: boolean-compare ( inverse-condition -- )
    2 0 4 LOAD.L 2 -4 5 LOAD.L 2 -4 2 LEA
    \ f type-number 0 MOVEQ
    0 1 MOVEI.L t rc-absolute-cell rel-literal 4 5 CMP.L
    [ inverse-condition Bcc ] [ 1 0 MOVE.L ] conditional
    0 2 0 STORE.L ;
: binary-inputs ( -- ) 2 0 4 LOAD.L 2 -4 5 LOAD.L 2 -4 2 LEA ;
: binary-result ( -- ) 5 2 0 STORE.L ;
: check-divisor ( -- )
    0 4 CMPI.L [ BNE ] [
        save-context 0 vm-arg "divide_by_zero" native-call
    ] conditional ;
: switch-context ( -- )
    ! A hardware return address anchors the suspended frame to its owner.
    2 BSR 0 5 MOVEA.L 5 4 vm-context-offset STOREA.L
    5 context-callstack-top-offset 7 LOADA.L load-stacks ;
: set-context ( -- )
    4 pop-ds 4 0 MOVEA.L 0 alien-offset 0 LOAD.L 5 pop-ds
    save-context switch-context 7 4 7 LEA 5 push-ds ;
: start-context ( -- )
    save-context 0 vm-arg "new_context" native-call* 0 0 MOVEAD.L
    4 pop-ds 5 pop-ds save-context switch-context
    5 push-ds 7 4 7 LEA 0 5 MOVEQ 5 PUSH.L jump-quot ;

{
    { c-to-factor [
        6 4 4 LOAD.L 4 7 4 STORE.L 0 vm-arg
        "begin_callback" native-call 0 4 MOVE.L call-quot
        0 vm-arg "end_callback" native-call
    ] }
    { unwind-native-frames [
        ! This entry is called directly from C and has no Factor prologue.
        7 4 4 LOAD.L 7 8 1 LOADA.L
        load-vm load-context load-stacks
        0 5 MOVEQ 5 4 vm-fault-flag-offset STORE.L
        1 7 MOVEAA.L jump-quot
    ] }
    { inline-cache-miss-resume [ prolog cache-miss epilog jump-return ] }
    { fpu-state [
        0 GET-FPCR 0 1 MOVEQ 1 SET-FPSR
        0x80 1 MOVEI.L 1 SET-FPCR
    ] }
    { set-fpu-state [ 7 16 0 LOAD.L 0 SET-FPCR ] }
    { leaf-signal-handler [
        signal-prolog signal-call signal-epilog
        12 RTD
    ] }
    { signal-handler [ signal-prolog signal-call signal-epilog RTS ] }
    { drop [ 2 -4 2 LEA ] }
    { 2drop [ 2 -8 2 LEA ] }
    { 3drop [ 2 -12 2 LEA ] }
    { 4drop [ 2 -16 2 LEA ] }
    { dup [ 2 0 4 LOAD.L 4 push-ds ] }
    { over [ 2 -4 4 LOAD.L 4 push-ds ] }
    { pick [ 2 -8 4 LOAD.L 4 push-ds ] }
    { swap [ 2 0 4 LOAD.L 2 -4 5 LOAD.L 4 2 -4 STORE.L 5 2 0 STORE.L ] }
    { swapd [ 2 -4 4 LOAD.L 2 -8 5 LOAD.L 4 2 -8 STORE.L 5 2 -4 STORE.L ] }
    { nip [ 4 pop-ds 4 2 0 STORE.L ] }
    { 2nip [ 4 pop-ds 2 -4 2 LEA 4 2 0 STORE.L ] }
    { 2dup [ 2 -4 4 LOAD.L 2 0 5 LOAD.L 4 push-ds 5 push-ds ] }
    { dupd [ 2 0 4 LOAD.L 2 -4 5 LOAD.L 5 2 0 STORE.L 4 push-ds ] }
    { 3dup [ 2 -8 4 LOAD.L 4 push-ds 2 -8 4 LOAD.L 4 push-ds 2 -8 4 LOAD.L 4 push-ds ] }
    { 4dup [ 2 -12 4 LOAD.L 4 push-ds 2 -12 4 LOAD.L 4 push-ds
             2 -12 4 LOAD.L 4 push-ds 2 -12 4 LOAD.L 4 push-ds ] }
    { rot [ 2 -8 4 LOAD.L 2 -4 5 LOAD.L 5 2 -8 STORE.L
            2 0 5 LOAD.L 5 2 -4 STORE.L 4 2 0 STORE.L ] }
    { -rot [ 2 0 4 LOAD.L 2 -4 5 LOAD.L 5 2 0 STORE.L
             2 -8 5 LOAD.L 5 2 -4 STORE.L 4 2 -8 STORE.L ] }
    { eq? [ 6 boolean-compare ] }
    { fixnum< [ 12 boolean-compare ] }
    { fixnum<= [ 14 boolean-compare ] }
    { fixnum> [ 15 boolean-compare ] }
    { fixnum>= [ 13 boolean-compare ] }
    { tag [ 2 0 4 LOAD.L tag-mask get 4 ANDI.L tag-bits get 4 LSL.L 4 2 0 STORE.L ] }
    { drop-locals [ 4 pop-ds tag-bits get 2 - 4 ASR.L 4 3 SUBA.L ] }
    { get-local [ 2 0 4 LOAD.L tag-bits get 2 - 4 ASR.L
        3 0 MOVEAA.L 4 0 ADDA.L 0 0 4 LOAD.L 4 2 0 STORE.L ] }
    { load-local [ >r ] }
    { both-fixnums? [
        binary-inputs 4 5 OR.L tag-mask get 5 ANDI.L
        \ f type-number 0 MOVEQ 1 tag-fixnum 1 MOVEI.L
        0 5 CMPI.L [ BNE ] [ 1 0 MOVE.L ] conditional 0 2 0 STORE.L
    ] }
    { fixnum+fast [ binary-inputs 4 5 ADD.L binary-result ] }
    { fixnum-fast [ binary-inputs 4 5 SUB.L binary-result ] }
    { fixnum-bitand [ binary-inputs 4 5 AND.L binary-result ] }
    { fixnum-bitor [ binary-inputs 4 5 OR.L binary-result ] }
    { fixnum-bitxor [ binary-inputs 4 5 XOR.L binary-result ] }
    { fixnum-bitnot [ 2 0 4 LOAD.L tag-mask get bitnot 4 XORI.L 4 2 0 STORE.L ] }
    { fixnum*fast [ binary-inputs tag-bits get 4 ASR.L 4 5 MULS.L binary-result ] }
    { fixnum+ [
        binary-inputs save-context 5 7 0 STORE.L 4 7 4 STORE.L 8 vm-arg
        4 5 ADD.L [ 8 Bcc ] [ "overflow_fixnum_add" native-call* 2 0 5 LOAD.L ] conditional
        ! The native overflow helper replaces the top stack value.
        5 2 0 STORE.L
    ] }
    { fixnum- [
        binary-inputs save-context 5 7 0 STORE.L 4 7 4 STORE.L 8 vm-arg
        4 5 SUB.L [ 8 Bcc ] [ "overflow_fixnum_subtract" native-call* 2 0 5 LOAD.L ] conditional
        5 2 0 STORE.L
    ] }
    { fixnum* [
        binary-inputs save-context 8 vm-arg
        tag-bits get 4 ASR.L 4 7 4 STORE.L
        5 0 MOVE.L tag-bits get 0 ASR.L 0 7 0 STORE.L
        4 5 0 MULS64.L
        5 1 MOVE.L 8 1 ASR.L 8 1 ASR.L 8 1 ASR.L 7 1 ASR.L
        1 0 CMP.L [ BEQ ] [
            "overflow_fixnum_multiply" native-call* 2 0 5 LOAD.L
        ] conditional binary-result
    ] }
    { fixnum-mod [ binary-inputs check-divisor 4 5 0 DIVREM.L 0 2 0 STORE.L ] }
    { fixnum/i-fast [ binary-inputs check-divisor 4 5 DIVS.L tag-bits get 5 LSL.L binary-result ] }
    { fixnum/mod-fast [
        2 0 4 LOAD.L 2 -4 5 LOAD.L check-divisor
        4 5 0 DIVREM.L tag-bits get 5 LSL.L 5 2 -4 STORE.L 0 2 0 STORE.L
    ] }
    { fixnum-shift-fast [
        binary-inputs tag-bits get 4 ASR.L 0 4 CMPI.L
        [ 10 Bcc ] [
            4 NEG.L 4 5 ASRR.L tag-mask get bitnot 5 ANDI.L
            4 BRA
        ] conditional
        4 5 LSLR.L binary-result
    ] }
    { slot [
        binary-inputs tag-bits get 2 - 4 ASR.L tag-mask get bitnot 5 ANDI.L
        5 0 MOVEA.L 4 0 ADDA.L 0 0 5 LOAD.L binary-result
    ] }
    { string-nth-fast [
        binary-inputs tag-bits get 5 ASR.L 4 0 MOVEA.L 5 0 ADDA.L
        0 5 MOVEQ 0 string-offset 5 LOAD.B tag-bits get 5 LSL.L binary-result
    ] }
    { set-callstack [
        4 pop-ds 4 0 MOVEA.L
        0 callstack-length-offset 5 LOAD.L tag-bits get 5 ASR.L
        0 callstack-top-offset 0 LEA
        5 context-callstack-bottom-offset 1 LOADA.L 5 1 SUBA.L 1 7 MOVEAA.L
        0 5 CMPI.L 28 BEQ
        0 0 4 LOAD.L 4 1 0 STORE.L 0 4 0 LEA 1 4 1 LEA
        4 5 SUBI.L -24 BNE RTS
    ] }
    { (set-context) [ set-context ] }
    { (set-context-and-delete) [ 0 vm-arg "delete_context" native-call set-context ] }
    { (start-context) [ start-context ] }
    { (start-context-and-delete) [
        save-context 0 vm-arg "reset_context" native-call*
        5 context-callstack-top-offset 7 LOADA.L load-stacks
        4 pop-ds 7 4 7 LEA 0 5 MOVEQ 5 PUSH.L jump-quot
    ] }
} define-sub-primitives

[ "bootstrap.assembler.m68k" forget-vocab ] with-compilation-unit
