! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: assocs bootstrap.image.private compiler.codegen.relocation
compiler.constants compiler.units compiler.cfg.comparisons cpu.sh cpu.sh.assembler cpu.sh.codegen
generic.single.private kernel kernel.private layouts locals locals.backend
make math math.bitwise math.private namespaces sequences slots.private
strings.private threads.private vocabs ;
IN: bootstrap.assembler.sh

4 \ cell set
sh-big-endian? get big-endian set

: aligned ( quot -- quot' ) [ call cpu.sh.codegen:align-code ] curry ;
: sh-jit-define ( quot n -- ) [ aligned ] dip jit-define ;
:: define-sh-combinator-primitive ( pre call tail word -- )
    pre aligned call aligned tail aligned word define-combinator-primitive ;
: define-sh-sub-primitives ( assoc -- ) [ aligned ] map-values define-sub-primitives ;

: prolog ( -- )
    SP SP -16 add-offset FP SP 0 SW temp STS-PR temp SP 4 SW FP SP MV ;
: epilog ( -- ) linked-epilog ;
: save-context ( -- )
    FP CTX context-callstack-top-offset SW
    DS CTX context-datastack-offset SW
    RS CTX context-retainstack-offset SW ;
: load-stacks ( -- )
    DS CTX context-datastack-offset LW RS CTX context-retainstack-offset LW ;
: load-context ( -- ) CTX VM vm-context-offset LW ;
: load-vm ( -- ) VM load-address 0 rc-absolute-cell rel-vm ;
: native-call ( name -- ) temp2 load-address f rc-absolute-cell rel-dlsym
    CALL rc-absolute-cell rel-trampoline ;
: native-call* ( name -- ) native-call load-stacks ;
: pop-ds ( reg -- ) DS 0 LW DS DS -4 add-offset ;
: push-ds ( reg -- ) DS DS 4 add-offset DS 0 SW ;
: >r ( -- ) 2 pop-ds RS RS 4 add-offset 2 RS 0 SW ;
: r> ( -- ) 2 RS 0 LW RS RS -4 add-offset 2 push-ds ;
: jump-word ( -- ) JUMP f rc-absolute-cell rel-word ;
: call-word ( -- ) CALL f rc-absolute-cell rel-word ;
: jump-quot ( -- ) temp 2 quot-entry-point-offset LW temp JMP NOP ;
: call-quot ( -- ) temp 2 quot-entry-point-offset LW temp JSR NOP ;
: jump-return ( -- ) temp JMP NOP ;
: call-return ( -- ) temp JSR NOP ;
! Assembler branches take a byte distance from the instruction address.
! jit-conditional emits a two-byte test before the measured arm.
: conditional ( test arm -- ) [ '[ 2 + @ ] ] dip jit-conditional ; inline

:: back-to ( destination -- )
    destination compiled-offset - BRA NOP ;
! Serialized linked frames store the distance to the preceding frame.
:: copy-linked-callstack ( -- )
    compiled-offset :> outer
    [ 5 6 CMP/HS BT ] [
        temp 4 0 LW temp2 4 4 LW FP 6 temp [ ADD ] binary-op
        FP 6 0 SW temp2 6 4 SW 4 4 8 add-offset 6 6 8 add-offset
        compiled-offset :> inner
        [ FP 6 CMP/HS BT ] [
            temp 4 0 LW temp 6 0 SW
            4 4 4 add-offset 6 6 4 add-offset inner back-to
        ] conditional
        outer back-to
    ] conditional ;

[ prolog ] JIT-PROLOG sh-jit-define
[ save-context 4 VM MV f native-call* ] JIT-PRIMITIVE sh-jit-define
[ PIC-TAIL load-address 4 rc-absolute-cell rel-here
  JUMP f rc-absolute-cell rel-word-pic-tail ] JIT-WORD-JUMP sh-jit-define
[ CALL f rc-absolute-cell rel-word-pic ] JIT-WORD-CALL sh-jit-define
[ 2 pop-ds temp \ f type-number LI temp 2 CMP/EQ
  [ BT ] [ jump-word ] conditional jump-word ] JIT-IF sh-jit-define
[ SAFEPOINT SAFEPOINT 0 SW ] JIT-SAFEPOINT sh-jit-define
[ epilog ] JIT-EPILOG sh-jit-define
[ RETURN ] JIT-RETURN sh-jit-define
[ 2 load-address f rc-absolute-cell rel-literal 2 push-ds ] JIT-PUSH-LITERAL sh-jit-define
[ >r call-word r> ] JIT-DIP sh-jit-define
[ >r >r call-word r> r> ] JIT-2DIP sh-jit-define
[ >r >r >r call-word r> r> r> ] JIT-3DIP sh-jit-define
[ 2 pop-ds temp 2 word-entry-point-offset LW temp JMP NOP ] JIT-EXECUTE sh-jit-define

! The native snapshot has hidden R2 and R4..R7 at 0..16, FR4..FR15
! at20..64, R8..R14 at68..92, PR96, FPSCR100 and the old context104.
! Native stack arguments start at snapshot+112. Keep this layout explicit
! so callbacks can recover arguments after begin_callback allocates.
: callback-stub ( -- )
    SP SP -112 add-offset
    2 SP 0 SW { 4 5 6 7 } [ 4 * 4 + SP swap SW ] each-index
    sh-soft-abi? get [ ] [
        temp STS-FPSCR temp SP 100 SW temp 0x80000 LI temp LDS-FPSCR
        { 4 5 6 7 8 9 10 11 12 13 14 15 }
        [ 4 * 20 + SP swap FSW ] each-index
    ] if
    { 8 9 10 11 12 13 14 } [ 4 * 68 + SP swap SW ] each-index
    temp STS-PR temp SP 96 SW
    load-vm load-context CTX SP 104 SW
    CTX VM vm-spare-context-offset LW CTX VM vm-context-offset SW
    SP CTX context-callstack-save-offset SW
    SP CTX context-callstack-bottom-offset LW SP SP 16 add-offset
    FP 0 LI load-stacks SAFEPOINT load-address rc-absolute-cell rel-safepoint
    call-word
    load-vm load-context SP CTX context-callstack-save-offset LW
    CTX SP 104 LW CTX VM vm-context-offset SW
    sh-soft-abi? get [ ] [
        { 12 13 14 15 } [ 4 * 52 + SP swap FLW ] each-index
        7 SP 100 LW 7 LDS-FPSCR
    ] if
    7 SP 96 LW 7 LDS-PR
    { 8 9 10 11 12 13 14 } [ 4 * 68 + SP swap LW ] each-index
    SP SP 112 add-offset RETURN ;
[ callback-stub ] CALLBACK-STUB sh-jit-define
CALLBACK-STUB special-objects get at dup suffix
CALLBACK-STUB special-objects get set-at

[ temp load-address f rc-absolute-cell rel-untagged
  DS temp ADD 2 temp 0 LW ] PIC-LOAD sh-jit-define
[ 3 2 MV temp tag-mask get LI temp 3 AND temp 0 LI temp 3 CMP/EQ ] PIC-TAG sh-jit-define
[ 3 2 MV temp tag-mask get LI temp 3 AND temp tuple type-number LI
  temp 3 CMP/EQ [ BF ] [ 3 2 tuple-class-offset LW ] conditional ] PIC-TUPLE sh-jit-define
[ temp load-address f rc-absolute-cell rel-untagged temp 3 CMP/EQ ] PIC-CHECK-TAG sh-jit-define
[ temp load-address f rc-absolute-cell rel-literal temp 3 CMP/EQ ] PIC-CHECK-TUPLE sh-jit-define
[ [ BF ] [ jump-word ] conditional ] PIC-HIT sh-jit-define
[ PIC-TAIL STS-PR jump-word ] PIC-MISS-JUMP sh-jit-define
[ jump-word ] PIC-MISS-TAIL-JUMP sh-jit-define
[ 3 2 MV temp tag-mask get LI temp 3 AND
  3 3 tag-bits get f sh-shift-immediate temp tuple type-number tag-fixnum LI
  temp 3 CMP/EQ [ BF ] [ 3 2 tuple-class-offset LW ] conditional
  4 load-address f rc-absolute-cell rel-literal
  temp mega-cache-size get 1 - bootstrap-cells LI 5 3 temp [ dup SHLR AND ] binary-op
  4 5 ADD 2 4 array-start-offset LW 2 3 CMP/EQ
  [ BF ] [
    temp load-address rc-absolute-cell rel-megamorphic-cache-hits
    2 temp 0 LW 2 2 1 add-offset 2 temp 0 SW
    temp 4 array-start-offset bootstrap-cell + LW
    temp temp word-entry-point-offset LW temp JMP NOP
  ] conditional ] MEGA-LOOKUP sh-jit-define

[ 2 pop-ds ] [ call-quot ] [ jump-quot ] \ (call) define-sh-combinator-primitive
[ 2 pop-ds temp 2 word-entry-point-offset LW ]
[ call-return ] [ jump-return ] \ (execute) define-sh-combinator-primitive
[ save-context 4 2 MV 5 VM MV "lazy_jit_compile" native-call*
  2 temp MV ] [ call-quot ] [ jump-quot ] \ lazy-jit-compile define-sh-combinator-primitive
: cache-miss ( -- )
    save-context 4 PIC-TAIL MV 5 VM MV
    temp2 load-address rc-absolute-cell rel-inline-cache-miss
    CALL rc-absolute-cell rel-trampoline load-stacks ;
[ PIC-TAIL FP 4 LW cache-miss ] [ call-return ] [ jump-return ]
\ inline-cache-miss define-sh-combinator-primitive
[ cache-miss ] [ call-return ] [ jump-return ]
\ inline-cache-miss-tail define-sh-combinator-primitive

! Measure a private, relocation-isolated body before materializing the resume
! PC. Its entry and exit are four-byte aligned, independent of its address.
:: resume-address ( body -- )
    [ body make-jit-no-params last length ] with-scope :> size
    temp load-address size rc-absolute-cell rel-here body call ; inline
: set-context-body ( -- )
    temp LDS-PR prolog save-context CTX 2 MV CTX VM vm-context-offset SW
    SP CTX context-callstack-top-offset LW load-stacks epilog RETURN ;
: set-context ( -- )
    2 pop-ds 2 2 alien-offset LW 3 pop-ds
    [ set-context-body ] resume-address 3 push-ds ;
: start-context-body ( -- )
    temp LDS-PR prolog save-context CTX 6 MV CTX VM vm-context-offset SW
    SP CTX context-callstack-bottom-offset LW SP SP 16 add-offset
    FP 0 LI load-stacks 3 push-ds temp 0 LI temp LDS-PR jump-quot ;
: start-context ( -- )
    save-context 4 VM MV "new_context" native-call* 6 temp MV
    2 pop-ds 3 pop-ds [ start-context-body ] resume-address 3 push-ds ;

! Save caller integer, FP, MAC, FPUL, PR, FPSCR and T state. SR itself is
! privileged; restore its user-visible T bit with a comparison instead.
: signal-prolog ( -- )
    -80 SP ADDI -80 SP ADDI
    { 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 } [ 4 * SP swap SW ] each-index
    temp MOVT temp SP 148 SW
    temp STS-PR temp SP 124 SW temp STS-MACL temp SP 128 SW
    temp STS-MACH temp SP 132 SW
    sh-soft-abi? get [ ] [
        temp STS-FPUL temp SP 136 SW
        temp STS-FPSCR temp SP 140 SW temp 0x80000 LI temp LDS-FPSCR
        { 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 }
        [ 4 * 60 + SP swap FSW ] each-index
    ] if load-vm load-context ;
: signal-epilog ( -- )
    sh-soft-abi? get [ ] [
        { 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 }
        [ 4 * 60 + SP swap FLW ] each-index
    ] if
    temp SP 128 LW temp LDS-MACL temp SP 132 LW temp LDS-MACH
    sh-soft-abi? get [ ] [
        temp SP 136 LW temp LDS-FPUL temp SP 140 LW temp LDS-FPSCR
    ] if
    temp SP 124 LW temp LDS-PR
    temp SP 148 LW temp2 1 LI temp2 temp CMP/EQ
    { 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 } [ 4 * SP swap LW ] each-index
    80 SP ADDI 80 SP ADDI ;
: signal-call ( -- )
    save-context temp VM vm-signal-handler-addr-offset LW temp JSR NOP ;
:: boolean-compare ( cc -- )
    2 pop-ds 3 DS 0 LW
    3 2 cc compare-t :> sense
    4 load-address t rc-absolute-cell rel-literal 2 \ f type-number LI
    [ sense [ BF ] [ BT ] if ] [ 2 4 MV ] conditional 2 DS 0 SW ;
: binary-inputs ( -- ) 2 pop-ds 3 DS 0 LW ;
: binary-result ( -- ) 3 DS 0 SW ;

{
    { c-to-factor [
        temp CTX context-callstack-save-offset LW 5 temp 4 LW
        4 VM MV "begin_callback" native-call 2 temp MV call-quot
        4 VM MV "end_callback" native-call
    ] }
    { unwind-native-frames [
        SP 5 MV epilog load-vm load-context load-stacks
        SAFEPOINT load-address rc-absolute-cell rel-safepoint
        temp 0 LI temp VM vm-fault-flag-offset SW 2 4 MV jump-quot
    ] }
    { inline-cache-miss-resume [ prolog cache-miss epilog jump-return ] }
    { fpu-state [ sh-soft-abi? get [ temp 0 LI ] [ temp STS-FPSCR temp2 0x80000 LI temp2 LDS-FPSCR ] if ] }
    { set-fpu-state [ sh-soft-abi? get [ ] [ 4 LDS-FPSCR ] if ] }
    { signal-handler [
        temp SP 8 SW FP SP 0 SW FP SP MV
        signal-prolog signal-call signal-epilog
        temp STS-PR temp SP 12 SW temp SP 4 LW temp LDS-PR
        FP SP 0 LW temp SP 8 LW SP SP 12 add-offset
        RTS SP LDS.L-PR
    ] }
    { leaf-signal-handler [
        temp SP 8 SW FP SP 16 SW temp STS-PR temp SP 20 SW
        temp SP 16 add-offset temp SP 0 SW FP SP MV
        signal-prolog signal-call signal-epilog
        temp SP 20 LW temp SP 28 SW temp SP 4 LW temp LDS-PR
        FP SP 16 LW temp SP 8 LW SP SP 28 add-offset
        RTS SP LDS.L-PR
    ] }
    { drop [ DS DS -4 add-offset ] }
    { 2drop [ DS DS -8 add-offset ] }
    { 3drop [ DS DS -12 add-offset ] }
    { 4drop [ DS DS -16 add-offset ] }
    { dup [ 2 DS 0 LW 2 push-ds ] }
    { over [ 2 DS -4 LW 2 push-ds ] }
    { pick [ 2 DS -8 LW 2 push-ds ] }
    { swap [ 2 DS 0 LW 3 DS -4 LW 2 DS -4 SW 3 DS 0 SW ] }
    { swapd [ 2 DS -4 LW 3 DS -8 LW 2 DS -8 SW 3 DS -4 SW ] }
    { nip [ 2 pop-ds 2 DS 0 SW ] }
    { 2nip [ 2 pop-ds DS DS -4 add-offset 2 DS 0 SW ] }
    { 2dup [ 2 DS -4 LW 3 DS 0 LW 2 push-ds 3 push-ds ] }
    { dupd [ 2 DS 0 LW 3 DS -4 LW 3 DS 0 SW 2 push-ds ] }
    { 3dup [ 2 DS -8 LW 2 push-ds 2 DS -8 LW 2 push-ds 2 DS -8 LW 2 push-ds ] }
    { 4dup [ 2 DS -12 LW 2 push-ds 2 DS -12 LW 2 push-ds
             2 DS -12 LW 2 push-ds 2 DS -12 LW 2 push-ds ] }
    { rot [ 2 DS -8 LW 3 DS -4 LW 3 DS -8 SW
            3 DS 0 LW 3 DS -4 SW 2 DS 0 SW ] }
    { -rot [ 2 DS 0 LW 3 DS -4 LW 3 DS 0 SW
             3 DS -8 LW 3 DS -4 SW 2 DS -8 SW ] }
    { eq? [ cc= boolean-compare ] }
    { fixnum< [ cc< boolean-compare ] }
    { fixnum<= [ cc<= boolean-compare ] }
    { fixnum> [ cc> boolean-compare ] }
    { fixnum>= [ cc>= boolean-compare ] }
    { tag [ 2 DS 0 LW temp tag-mask get LI temp 2 AND
            2 2 tag-bits get f sh-shift-immediate 2 DS 0 SW ] }
    { drop-locals [ 2 pop-ds 2 2 tag-bits get 2 - neg t sh-shift-immediate 2 RS SUB ] }
    { get-local [ 2 DS 0 LW 2 2 tag-bits get 2 - neg t sh-shift-immediate
                  RS 2 ADD 2 2 0 LW 2 DS 0 SW ] }
    { load-local [ >r ] }
    { both-fixnums? [
        binary-inputs 2 3 OR temp tag-mask get LI temp 3 AND
        temp 0 LI temp 3 CMP/EQ
        3 \ f type-number LI [ BF ] [ 3 1 tag-fixnum LI ] conditional binary-result
    ] }
    { fixnum+fast [ binary-inputs 2 3 ADD binary-result ] }
    { fixnum-fast [ binary-inputs 2 3 SUB binary-result ] }
    { fixnum-shift-fast [
        binary-inputs 2 2 tag-bits get neg t sh-shift-immediate
        3 3 2 t sh-shift temp tag-mask get bitnot LI temp 3 AND binary-result
    ] }
    { fixnum+ [
        5 pop-ds 4 DS 0 LW save-context 3 4 5 [ ADD ] binary-op 3 DS 0 SW
        temp 4 MV 3 temp XOR temp2 5 MV 3 temp2 XOR temp2 temp AND
        temp2 0 LI temp2 temp CMP/GE
        [ BT ] [ 6 VM MV "overflow_fixnum_add" native-call* ] conditional
    ] }
    { fixnum- [
        5 pop-ds 4 DS 0 LW save-context 3 4 5 [ SUB ] binary-op 3 DS 0 SW
        temp 4 MV 5 temp XOR temp2 4 MV 3 temp2 XOR temp2 temp AND
        temp2 0 LI temp2 temp CMP/GE
        [ BT ] [ 6 VM MV "overflow_fixnum_subtract" native-call* ] conditional
    ] }
    { fixnum* [
        5 pop-ds 4 DS 0 LW save-context
        4 4 tag-bits get neg t sh-shift-immediate 5 4 DMULS.L
        3 STS-MACL 3 DS 0 SW 2 STS-MACH
        temp2 3 -31 t sh-shift-immediate 2 temp2 CMP/EQ
        [ BT ] [
            5 5 tag-bits get neg t sh-shift-immediate
            6 VM MV "overflow_fixnum_multiply" native-call*
        ] conditional
    ] }
    ! Classic SH has no scalar divide instruction; use the VM's checked
    ! scalar implementation without enabling an unsupported intrinsic.
    { fixnum/i-fast [ save-context 4 VM MV "primitive_fixnum_divint" native-call* ] }
    { fixnum/mod-fast [ save-context 4 VM MV "primitive_fixnum_divmod" native-call* ] }
    { fixnum-mod [
        save-context 4 VM MV "primitive_fixnum_divmod" native-call*
        2 pop-ds 2 DS 0 SW
    ] }
    { fixnum-bitand [ binary-inputs 2 3 AND binary-result ] }
    { fixnum-bitor [ binary-inputs 2 3 OR binary-result ] }
    { fixnum-bitxor [ binary-inputs 2 3 XOR binary-result ] }
    { fixnum-bitnot [ 2 DS 0 LW 2 2 NOT temp tag-mask get bitnot LI temp 2 AND 2 DS 0 SW ] }
    { fixnum*fast [ binary-inputs 2 2 tag-bits get neg t sh-shift-immediate
                   2 3 MUL.L 3 STS-MACL binary-result ] }
    { slot [ binary-inputs 2 2 tag-bits get 2 - neg t sh-shift-immediate
             temp tag-mask get bitnot LI temp 3 AND 2 3 ADD 3 3 0 LW binary-result ] }
    { string-nth-fast [ binary-inputs 3 3 tag-bits get neg t sh-shift-immediate
                       2 3 ADD 3 3 string-offset add-offset 3 3 MOV.B 3 3 EXTU.B
                       3 3 tag-bits get f sh-shift-immediate binary-result ] }
    { set-callstack [
        2 pop-ds 5 CTX context-callstack-bottom-offset LW
        4 2 callstack-top-offset add-offset temp 2 callstack-length-offset LW
        temp temp tag-bits get neg t sh-shift-immediate
        6 5 temp [ SUB ] binary-op SP 6 MV copy-linked-callstack epilog RETURN
    ] }
    { (set-context) [ set-context ] }
    { (set-context-and-delete) [ save-context 4 VM MV "delete_context" native-call set-context ] }
    { (start-context) [ start-context ] }
    { (start-context-and-delete) [
        save-context 4 VM MV "reset_context" native-call* SP CTX context-callstack-top-offset LW
        ! Match fresh context entry: the zero-return outer frame is at bottom.
        SP SP 16 add-offset FP 0 LI 2 pop-ds temp 0 LI temp LDS-PR jump-quot
    ] }
} define-sh-sub-primitives

[ "bootstrap.assembler.sh" forget-vocab ] with-compilation-unit
