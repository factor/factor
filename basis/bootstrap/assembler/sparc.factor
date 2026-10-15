! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: assocs bootstrap.image.private compiler.codegen.relocation
compiler.constants compiler.units cpu.sparc.assembler generic.single.private
kernel kernel.private layouts literals locals locals.backend make math
math.bitwise math.private namespaces sequences slots.private strings.private
threads.private vocabs ;
IN: bootstrap.assembler.sparc

! Globals survive register-window rotation. Native calls invalidate g5.
CONSTANT: DS 2
CONSTANT: RS 3
CONSTANT: VM 4
CONSTANT: CTX 5
CONSTANT: SP 14
CONSTANT: FP 30
: move ( rd rs -- ) 0 ORI ;
: load-context ( -- ) CTX VM vm-context-offset load-cell ;
: load-stacks ( -- )
    load-context
    DS CTX context-datastack-offset load-cell
    RS CTX context-retainstack-offset load-cell ;
: save-context ( -- )
    ! Fault in Factor code while the current window can still be spilled.
    ! A native SAVE across the guard can prevent kernel signal delivery.
    1 SP stack-bias 4096 - load-cell
    ! FLUSHW commits older windows only; the live window needs explicit stores.
    { 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 }
    [ cell-size * stack-bias + SP swap store-cell ] each-index
    flush-windows load-context
    1 SP stack-bias ADDI 1 CTX context-callstack-top-offset store-cell
    DS CTX context-datastack-offset store-cell
    RS CTX context-retainstack-offset store-cell ;
: prolog ( -- )
    0 SP stack-bias stack-frame - load-cell
    SP SP stack-frame neg SAVEI ;
! Rotate back before the separate JIT-RETURN. This leaves o7 restored.
: epilog ( -- ) RESTORE0 ;
: leaf-return ( -- ) RETL NOP ;
: native-call ( name -- )
    f 1 load-address rel-dlsym 15 load-address rel-trampoline
    15 15 0 JMPLI NOP ;
: call-word ( -- )
    0 CALL f rc-native-0 rel-word NOP ;
! Frameless dispatch shares the caller window; reserve outgoing o5 only.
: load-pic-address ( rd -- class )
    cell-size 8 = [ 13 0 SET64 ] [ 0 SET32 ] if rc-native-1 ;
: jump-word ( -- )
    f 1 load-pic-address rel-word 0 1 0 JMPLI NOP ;
: jump-pic-word ( -- )
    f 1 load-pic-address rel-word 0 1 0 JMPLI NOP ;
: pop-ds ( rd -- ) DS 0 load-cell DS DS cell-size neg ADDI ;
: push-ds ( rd -- ) DS DS cell-size ADDI DS 0 store-cell ;
: push-r ( -- ) 8 pop-ds RS RS cell-size ADDI 8 RS 0 store-cell ;
: pop-r ( -- ) 8 RS 0 load-cell RS RS cell-size neg ADDI 8 push-ds ;
: call-quot ( -- ) 1 8 quot-entry-point-offset load-cell 15 1 0 JMPLI NOP ;
: jump-quot ( -- ) 1 8 quot-entry-point-offset load-cell 0 1 0 JMPLI NOP ;
: compare ( a b -- ) [ 0 ] 2dip SUBcc ;
: compare-imm ( a n -- ) [ 0 ] 2dip SUBccI ;
! jit-conditional measures an eight-byte branch including its delay slot.
: conditional ( condition quot -- )
    [ '[ 8 + _ swap branch ] ] dip jit-conditional ; inline

: load-live-i7 ( -- )
    31 SP frame-return-offset load-cell
    0 31 3 ANDccI
    1 [
        "factor_sparc_window_cookie" f 1 load-address rel-dlsym
        1 1 0 load-cell 31 31 1 XOR
    ] conditional ;
: native-call* ( name -- )
    native-call load-stacks load-live-i7 ;

[ prolog ] JIT-PROLOG jit-define
[ save-context 8 VM move f native-call* ] 2 make-jit-with-parameters
JIT-PRIMITIVE special-objects get set-at
[ 0 CALL f rc-native-0 rel-word-pic NOP ] JIT-WORD-CALL jit-define
[
    ! CALL reads PC on both V8/V9. Preserve the caller return address.
    13 15 move 8 CALL NOP
    12 15 cell-size 4 = [ 32 ] [ 48 ] if ADDI 15 13 move
    ! The quotation epilogue restored the caller's register window.
    f 1 load-pic-address rel-word-pic-tail 0 1 0 JMPLI NOP
] JIT-WORD-JUMP jit-define
[
    8 pop-ds 8 \ f type-number compare-imm
    1 [ jump-word ] conditional jump-word
] JIT-IF jit-define
[ epilog ] JIT-EPILOG jit-define
[ leaf-return ] JIT-RETURN jit-define
! Literal-only quotations have no SAVE and share the caller window.
[ f 8 load-pic-address rel-literal 8 push-ds ] JIT-PUSH-LITERAL jit-define
[ push-r call-word pop-r ] JIT-DIP jit-define
[ push-r push-r call-word pop-r pop-r ] JIT-2DIP jit-define
[ push-r push-r push-r call-word pop-r pop-r pop-r ] JIT-3DIP jit-define
[ 8 pop-ds 1 8 word-entry-point-offset load-cell 0 1 0 JMPLI NOP ] JIT-EXECUTE jit-define
[ 1 load-address rel-safepoint 0 1 0 store-cell ] JIT-SAFEPOINT jit-define

! SAVE protects all native nonvolatile window registers. Globals are saved
! explicitly because Factor assigns its persistent stacks to g2..g4.
: callback-frame ( -- n ) stack-frame cell-size 8 * + 16 align ;
: callback-save-offset ( -- n ) stack-frame stack-bias + ;
[
    SP SP callback-frame neg SAVEI
    22 FP stack-bias ADDI
    { 2 3 4 5 } [ cell-size * callback-save-offset + SP swap store-cell ] each-index
    0 VM load-address rel-vm
    load-context 16 CTX move
    CTX VM vm-spare-context-offset load-cell CTX VM vm-context-offset store-cell
    SP CTX context-callstack-save-offset store-cell
    SP CTX context-callstack-bottom-offset load-cell SP SP stack-bias neg ADDI
    load-stacks
    22 SP stack-bias cell-size 6 * + store-cell
    8 24 move 9 25 move 10 26 move 11 27 move 12 28 move 13 29 move
    f 1 load-address rel-word 15 1 0 JMPLI NOP
    24 8 move 25 9 move 26 10 move 27 11 move
    load-context SP CTX context-callstack-save-offset load-cell
    16 VM vm-context-offset store-cell
    { 2 3 4 5 } [ cell-size * callback-save-offset + SP swap load-cell ] each-index
    ! GNU V8 structure returns skip the caller's UNIMP size marker.
    cell-size 4 = [ f 1 load-address rel-untagged 31 31 1 ADD ] when
    RET RESTORE0
] CALLBACK-STUB jit-define

! PICs use outgoing registers so their entry requires no SAVE.
[ f 1 load-pic-address rel-untagged 8 DS 1 load-cell-x ] PIC-LOAD jit-define
[ 9 8 tag-mask get ANDccI ] PIC-TAG jit-define
[
    9 8 tag-mask get ANDI 9 tuple type-number compare-imm
    9 [ 9 8 tuple-class-offset load-cell ] conditional
] PIC-TUPLE jit-define
[ f 1 load-pic-address rel-untagged 9 1 compare ] PIC-CHECK-TAG jit-define
[ f 1 load-pic-address rel-literal 9 1 compare ] PIC-CHECK-TUPLE jit-define
[ 9 [ jump-pic-word ] conditional ] PIC-HIT jit-define
[ 12 15 8 ADDI jump-pic-word ] PIC-MISS-JUMP jit-define
[ jump-pic-word ] PIC-MISS-TAIL-JUMP jit-define
[
    9 8 tag-mask get ANDI 9 9 tag-bits get shift-left
    9 tuple type-number tag-fixnum compare-imm
    9 [ 9 8 tuple-class-offset load-cell ] conditional
    f 10 load-pic-address rel-literal
    11 9 cell-size 4 = [ 1 SRLI 11 11 ] when
    mega-cache-size get 1 - bootstrap-cells ANDI
    10 10 11 ADD 11 10 array-start-offset load-cell
    9 11 compare
    9 [
        1 load-pic-address rel-megamorphic-cache-hits
        11 1 0 load-cell 11 11 1 ADDI 11 1 0 store-cell
        1 10 array-start-offset cell-size + load-cell
        1 1 word-entry-point-offset load-cell 0 1 0 JMPLI NOP
    ] conditional
] MEGA-LOOKUP jit-define

[ 8 pop-ds 24 8 move 1 8 quot-entry-point-offset load-cell ]
[ 15 1 0 JMPLI NOP ] [ 0 1 0 JMPLI NOP ] \ (call) define-combinator-primitive
[ 8 pop-ds 1 8 word-entry-point-offset load-cell ]
[ 15 1 0 JMPLI NOP ] [ 0 1 0 JMPLI NOP ] \ (execute) define-combinator-primitive
[ save-context 8 24 move 9 VM move "lazy_jit_compile" native-call*
  24 8 move 1 8 quot-entry-point-offset load-cell ]
[ 15 1 0 JMPLI NOP ] [ 0 1 0 JMPLI NOP ] \ lazy-jit-compile define-combinator-primitive
: cache-miss ( -- )
    save-context 8 12 move 9 VM move "inline_cache_miss" native-call* ;
[ 12 31 8 ADDI cache-miss 1 8 move ]
[ 15 1 0 JMPLI NOP ] [ 0 1 0 JMPLI NOP ] \ inline-cache-miss define-combinator-primitive
[ 12 28 move cache-miss 1 8 move ]
[ 15 1 0 JMPLI NOP ] [ 0 1 0 JMPLI NOP ] \ inline-cache-miss-tail define-combinator-primitive

:: math-op ( insn -- )
    8 pop-ds 9 DS 0 load-cell 8 9 8 insn call( rd a b -- ) 8 DS 0 store-cell ;
:: comparison ( condition -- )
    8 pop-ds 9 DS 0 load-cell 9 8 compare
    t 8 load-address rel-literal
    condition 12 branch 8 0 \ f type-number ORI
    8 DS 0 store-cell ;

: check-divisor ( -- )
    8 0 compare-imm
    9 [ save-context 8 VM move "divide_by_zero" native-call* ] conditional ;
:: overflow-op ( instruction overflow-condition name -- )
    9 pop-ds 8 DS 0 load-cell save-context
    11 8 9 instruction call( rd a b -- ) 11 DS 0 store-cell
    overflow-condition [ 10 VM move name native-call* ] conditional ;

: restore-window ( -- )
    "sparc_restore_window" f 1 load-address rel-dlsym 0 1 0 JMPLI NOP ;
: restore-quotation-window ( -- )
    ! The helper consumes o0 as a physical frame. Preserve the quotation in o2
    ! and restore its normal entry argument only after switching windows.
    cell-size 4 = [ 16 ] [ 32 ] if 9 load-address rel-here
    restore-window
    8 10 move jump-quot ;
:: suspend-context ( dispatch -- )
    ! A synthetic SAVE preserves the surrounding frame. Its saved i7 points
    ! at the continuation after dispatch, rather than at the caller's return.
    SP SP stack-frame neg SAVEI
    dispatch [ make-jit 2nip second length ] with-scope 8 -
    31 load-address rel-here
    dispatch call( -- )
    10 push-ds RESTORE0 ;
: dispatch-context ( -- )
    save-context CTX 24 move CTX VM vm-context-offset store-cell
    8 CTX context-callstack-top-offset load-cell
    9 8 cell-size 15 * load-cell 9 9 8 ADDI
    10 25 move load-stacks restore-window ;
: pop-context ( -- )
    8 pop-ds 8 8 alien-offset load-cell 9 pop-ds ;

: start-context-dispatch ( -- )
    save-context CTX 24 move CTX VM vm-context-offset store-cell
    load-stacks 26 push-ds
    8 CTX context-callstack-top-offset load-cell
    10 25 move restore-quotation-window ;

: signal-dispatch ( -- )
    ! Native dispatch installs a fake window and a cloned kernel rt frame.
    ! Kernel sigreturn restores both PC and NPC, including delay-slot faults.
    30 SP frame-link-offset load-cell load-live-i7
    save-context 1 VM vm-signal-handler-addr-offset load-cell
    15 load-address rel-trampoline 15 15 0 JMPLI NOP load-stacks
    8 SP stack-bias stack-frame + load-cell
    "sparc_signal_resume_frame" native-call
    "sparc_rt_sigreturn" f 1 load-address rel-dlsym 0 1 0 JMPLI NOP ;


{
    { drop [ DS DS cell-size neg ADDI ] }
    { 2drop [ DS DS cell-size -2 * ADDI ] }
    { 3drop [ DS DS cell-size -3 * ADDI ] }
    { 4drop [ DS DS cell-size -4 * ADDI ] }
    { dup [ 8 DS 0 load-cell 8 push-ds ] }
    { over [ 8 DS cell-size neg load-cell 8 push-ds ] }
    { pick [ 8 DS cell-size -2 * load-cell 8 push-ds ] }
    { 2dup [ 8 DS cell-size neg load-cell 9 DS 0 load-cell 8 push-ds 9 push-ds ] }
    { 4dup [ 8 DS cell-size -3 * load-cell 9 DS cell-size -2 * load-cell 10 DS cell-size neg load-cell 11 DS 0 load-cell 8 push-ds 9 push-ds 10 push-ds 11 push-ds ] }
    { 3dup [ 8 DS cell-size -2 * load-cell 9 DS cell-size neg load-cell 10 DS 0 load-cell 8 push-ds 9 push-ds 10 push-ds ] }
    { dupd [ 8 DS cell-size neg load-cell 9 DS 0 load-cell 8 DS 0 store-cell 9 push-ds ] }
    { nip [ 8 pop-ds 8 DS 0 store-cell ] }
    { 2nip [ 8 pop-ds DS DS cell-size neg ADDI 8 DS 0 store-cell ] }
    { swap [ 8 DS 0 load-cell 9 DS cell-size neg load-cell 8 DS cell-size neg store-cell 9 DS 0 store-cell ] }
    { swapd [ 8 DS cell-size neg load-cell 9 DS cell-size -2 * load-cell 8 DS cell-size -2 * store-cell 9 DS cell-size neg store-cell ] }
    { rot [ 8 DS 0 load-cell 9 DS cell-size neg load-cell 10 DS cell-size -2 * load-cell 9 DS cell-size -2 * store-cell 8 DS cell-size neg store-cell 10 DS 0 store-cell ] }
    { -rot [ 8 DS 0 load-cell 9 DS cell-size neg load-cell 10 DS cell-size -2 * load-cell 8 DS cell-size -2 * store-cell 10 DS cell-size neg store-cell 9 DS 0 store-cell ] }
    { eq? [ 1 comparison ] }
    { fixnum< [ 3 comparison ] }
    { fixnum<= [ 2 comparison ] }
    { fixnum> [ 10 comparison ] }
    { fixnum>= [ 11 comparison ] }
    { fixnum+fast [ [ ADD ] math-op ] }
    { fixnum-fast [ [ SUB ] math-op ] }
    { fixnum-bitand [ [ AND ] math-op ] }
    { fixnum-bitor [ [ OR ] math-op ] }
    { fixnum-bitxor [ [ XOR ] math-op ] }
    { fixnum-bitnot [ 8 DS 0 load-cell 8 8 tag-mask get XNORI 8 DS 0 store-cell ] }
    { both-fixnums? [
        8 pop-ds 9 DS 0 load-cell 8 8 9 OR 8 8 tag-mask get ANDI
        8 0 compare-imm 8 0 \ f type-number ORI
        9 [ 8 0 1 tag-fixnum ORI ] conditional 8 DS 0 store-cell
    ] }
    { fixnum+ [ [ ADDcc ] 15 "overflow_fixnum_add" overflow-op ] }
    { fixnum- [ [ SUBcc ] 15 "overflow_fixnum_subtract" overflow-op ] }
    { fixnum* [
        9 pop-ds 8 DS 0 load-cell save-context 8 8 tag-bits get shift-right
        11 8 9 multiply 11 DS 0 store-cell 9 0 compare-imm
        1 [
            product-quotient-check
            1 [ 9 9 tag-bits get shift-right 10 VM move "overflow_fixnum_multiply" native-call* ] conditional
        ] conditional
    ] }
    { fixnum*fast [ 8 pop-ds 9 DS 0 load-cell 8 8 tag-bits get shift-right 8 9 8 multiply 8 DS 0 store-cell ] }
    { fixnum-mod [ 8 pop-ds 9 DS 0 load-cell check-divisor 10 9 8 divide 10 10 8 multiply 9 9 10 SUB 9 DS 0 store-cell ] }
    { fixnum/i-fast [ 8 pop-ds 9 DS 0 load-cell check-divisor 10 9 8 divide 10 10 tag-bits get shift-left 10 DS 0 store-cell ] }
    { fixnum/mod-fast [ 8 DS 0 load-cell 9 DS cell-size neg load-cell check-divisor 10 9 8 divide 11 10 8 multiply 11 9 11 SUB 10 10 tag-bits get shift-left 10 DS cell-size neg store-cell 11 DS 0 store-cell ] }
    { fixnum-shift-fast [
        8 pop-ds 9 DS 0 load-cell 8 8 tag-bits get shift-right
        10 9 8 shift-left-reg 8 0 compare-imm
        11 [ 8 0 8 SUB 10 9 8 shift-right-reg 10 10 tag-mask get bitnot ANDI ] conditional
        10 DS 0 store-cell
    ] }
    { tag [ 8 DS 0 load-cell 8 8 tag-mask get ANDI 8 8 tag-bits get shift-left 8 DS 0 store-cell ] }
    { load-local [ push-r ] }
    { drop-locals [ 8 pop-ds 8 8 tag-bits get cell-size log2 - shift-right RS RS 8 SUB ] }
    { get-local [ 8 DS 0 load-cell 8 8 tag-bits get cell-size log2 - shift-right 8 RS 8 load-cell-x 8 DS 0 store-cell ] }
    { slot [ 8 pop-ds 9 DS 0 load-cell 8 8 tag-bits get cell-size log2 - shift-right 9 9 tag-mask get bitnot ANDI 8 9 8 load-cell-x 8 DS 0 store-cell ] }
    { string-nth-fast [ 8 pop-ds 9 DS 0 load-cell 9 9 tag-bits get shift-right 8 8 9 ADD 8 8 string-offset LDUB 8 8 tag-bits get shift-left 8 DS 0 store-cell ] }
    { (set-context) [ pop-context [ dispatch-context ] suspend-context ] }
    { (set-context-and-delete) [
        pop-context 16 8 move 17 9 move
        save-context 8 VM move "delete_context" native-call
        8 16 move 9 17 move [ dispatch-context ] suspend-context
    ] }
    { (start-context) [
        save-context 8 VM move "new_context" native-call* 16 8 move
        9 pop-ds 10 pop-ds 8 16 move
        [ start-context-dispatch ] suspend-context
    ] }
    { (start-context-and-delete) [
        save-context 8 VM move "reset_context" native-call* load-context
        10 pop-ds
        8 CTX context-callstack-top-offset load-cell restore-quotation-window
    ] }
    { set-callstack [
        ! Retire native continuations before replacing their physical frames.
        ! Keep the captured stack rooted on the data stack across the call.
        save-context 8 VM move "factor_sparc_prepare_callstack" native-call
        load-stacks 8 pop-ds save-context
        20 CTX context-callstack-bottom-offset load-cell
        9 8 callstack-top-offset ADDI
        10 8 callstack-length-offset load-cell 10 10 tag-bits get shift-right
        16 20 10 SUB 8 16 move
        ! Keep the live window below the copied stack. A later window flush
        ! spills its registers at SP, which must not overwrite captured links.
        SP 16 stack-bias stack-frame + neg ADDI
        "factor_memcpy" native-call
        ! Recover the destination from memcpy and the bottom from the context
        ! before traversing the copied chain.
        16 8 move load-context 20 CTX context-callstack-bottom-offset load-cell
        ! Linux/NetBSD export zero; OpenBSD exports its live window cookie.
        ! Load data without a native call while the copied links are relative.
        "factor_sparc_window_cookie" f 21 load-address rel-dlsym
        21 21 0 load-cell
        17 16 move 17 20 compare
        1 [
            ! Captured i6 slots hold relative frame sizes, not biased pointers.
            18 17 cell-size 14 * load-cell 19 17 18 ADD
            19 19 stack-bias neg ADDI 19 17 cell-size 14 * store-cell
            ! Captures store raw i7; kernel window fills require live encoding.
            22 17 cell-size 15 * load-cell 22 22 21 XOR
            22 17 cell-size 15 * store-cell
            17 17 18 ADD 17 20 compare 9 -36 branch
        ] conditional
        load-stacks 8 16 move
        cell-size 4 = [ 16 ] [ 32 ] if 9 load-address rel-here
        restore-window RET RESTORE0
    ] }
    { unwind-native-frames [
        16 8 move 17 9 move
        0 VM load-address rel-vm load-stacks
        0 VM vm-fault-flag-offset store-cell
        8 17 move 10 16 move
        cell-size 4 = [ 16 ] [ 32 ] if 9 load-address rel-here
        restore-window
        ! Discard the captured native frame, restoring its caller's o7.
        24 10 move 1 10 quot-entry-point-offset load-cell
        RESTORE0 0 1 0 JMPLI NOP
    ] }
    { signal-handler [ signal-dispatch ] }
    { leaf-signal-handler [ signal-dispatch ] }
    { fpu-state [
        fsr-register SP stack-bias cell-size 16 * + 37 mem-imm
        24 SP stack-bias cell-size 16 * + load-cell
        0 SP stack-bias cell-size 16 * + store-cell
        fsr-register SP stack-bias cell-size 16 * + 33 mem-imm
    ] }
    { set-fpu-state [
        24 SP stack-bias cell-size 16 * + store-cell
        fsr-register SP stack-bias cell-size 16 * + 33 mem-imm
    ] }
    { c-to-factor [
        9 24 move save-context 8 VM move "begin_callback" native-call*
        call-quot save-context 8 VM move "end_callback" native-call*
    ] }
    { inline-cache-miss-resume [ prolog 12 28 move cache-miss 1 8 move epilog 0 1 0 JMPLI NOP ] }
} define-sub-primitives

[ "bootstrap.assembler.sparc" forget-vocab ] with-compilation-unit
