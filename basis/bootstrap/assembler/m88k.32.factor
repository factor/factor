! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs bootstrap.image.private compiler.cfg.comparisons
compiler.codegen.relocation compiler.constants compiler.units cpu.m88k
cpu.m88k.assembler cpu.m88k.assembler.registers generic.single.private
kernel kernel.private layouts literals locals locals.backend make math
math.bitwise math.private namespaces sequences slots.private strings.private
threads.private vocabs ;
IN: bootstrap.assembler.m88k

4 \ cell set
big-endian on

ALIAS: arg1 R2
ALIAS: arg2 R3
ALIAS: arg3 R4
ALIAS: RETURN R2
ALIAS: ds-0 R4
ALIAS: ds-1 R5
ALIAS: ds-2 R6
ALIAS: ds-3 R7
ALIAS: obj R4
ALIAS: type R5
ALIAS: cache R6
ALIAS: src R6
ALIAS: top R7
ALIAS: bottom R8
ALIAS: temp1 R9
ALIAS: IP0 IP
ALIAS: FP SP

: MV ( rd rs -- ) [ ZERO ] dip OR ;
: LI ( rd value -- ) load-immediate ;
: native-address ( dst -- class ) 0 LI32 rc-native-0 ;
: ADDI ( rd rs imm -- ) add-offset ;
: ADD ( rd rs rt -- ) ADDU ;
: SUB ( rd rs rt -- ) SUBU ;
: LW ( rd base offset -- ) memory-offset LD ;
: SW ( rs base offset -- ) memory-offset ST ;
: LBU ( rd base offset -- ) memory-offset LDBU ;
:: ANDI ( rd rs imm -- ) R13 imm load-immediate rd rs R13 AND ;
:: XORI ( rd rs imm -- ) R13 imm load-immediate rd rs R13 XOR ;
: SLLI ( rd rs n -- ) MAKI ;
: SRLI ( rd rs n -- ) EXTUI ;
: SRAI ( rd rs n -- ) EXTI ;
: NEG ( rd rs -- ) [ ZERO ] dip SUBU ;
: JR ( rs -- ) JMP ;
: J ( displacement -- ) BR ;
:: JALR ( link target offset -- ) link drop offset drop target JSR ;
:: compare-branch ( left right displacement cc -- )
    R13 left right CMP cc compare-index R13 displacement BB1 ;
: BEQ ( left right displacement -- ) cc= compare-branch ;
: BNE ( left right displacement -- ) cc/= compare-branch ;
: BLT ( left right displacement -- ) cc< compare-branch ;
: BGE ( left right displacement -- ) cc>= compare-branch ;
:: BLTU ( left right displacement -- )
    R13 left right CMP 10 R13 displacement BB1 ;
:: BGEU ( left right displacement -- )
    R13 left right CMP 11 R13 displacement BB1 ;
: word-jump ( literal -- ) IP load-address rel-word IP JMP ;
: word-call ( literal -- ) IP load-address rel-word IP JSR ;

: save-context ( -- )
    SP CTX context-callstack-top-offset ST
    DS CTX context-datastack-offset ST RS CTX context-retainstack-offset ST ;
: load-stacks ( -- )
    DS CTX context-datastack-offset LD RS CTX context-retainstack-offset LD ;
: prolog ( -- )
    temp2 SP MV SP SP 16 SUBUI temp2 SP 0 ST RA SP 4 ST ;
: epilog ( -- ) RA SP 4 LD SP SP 0 LD ;
: native-call ( name -- )
    f IP load-address rel-dlsym TRAMPOLINE JSR ;
: native-call* ( name -- ) native-call load-stacks ;
: pop-ds ( rd -- ) DS 0 LD DS DS 4 SUBUI ;
: push-ds ( rs -- ) DS DS 4 ADDUI DS 0 ST ;
: >r ( -- ) ds-0 pop-ds RS RS 4 ADDUI ds-0 RS 0 ST ;
: r> ( -- ) ds-0 RS 0 LD RS RS 4 SUBUI ds-0 push-ds ;

[ prolog ] JIT-PROLOG jit-define
[ save-context arg1 VM MV f native-call* ] JIT-PRIMITIVE jit-define
[ f PIC-TAIL load-address rel-here f IP load-address rel-word-pic-tail IP JMP ] JIT-WORD-JUMP jit-define
[ f IP load-address rel-word-pic IP JSR ] JIT-WORD-CALL jit-define
[
    ds-0 pop-ds temp \ f type-number LI
    [ ds-0 temp rot BEQ ] [ f word-jump ] jit-conditional*
    f word-jump
] JIT-IF jit-define
[ SAFEPOINT SAFEPOINT 0 ST ] JIT-SAFEPOINT jit-define
[ epilog ] JIT-EPILOG jit-define
[ RET ] JIT-RETURN jit-define
[ f ds-0 load-address rel-literal ds-0 push-ds ] JIT-PUSH-LITERAL jit-define
[ >r f word-call r> ] JIT-DIP jit-define
[ >r >r f word-call r> r> ] JIT-2DIP jit-define
[ >r >r >r f word-call r> r> r> ] JIT-3DIP jit-define
[ temp pop-ds temp temp word-entry-point-offset LD temp JMP ] JIT-EXECUTE jit-define

! Native callbacks retain the GNU incoming argument snapshot separately.
:: jit-callback-stub ( varargs? -- )
    varargs? drop
    SP SP 128 SUBUI
    12 <iota> [ 14 + int-register boa SP rot 4 * ST ] each-index
    R30 SP 48 ST RA SP 52 ST
    8 <iota> [ 2 + int-register boa SP rot 4 * 96 + ST ] each-index
    0 VM load-address rel-vm
    CTX VM vm-context-offset LD CTX SP 56 ST
    SAFEPOINT native-address rel-safepoint
    TRAMPOLINE native-address rel-trampoline
    TRAMPOLINE2 native-address rel-trampoline2
    CTX VM vm-spare-context-offset LD CTX VM vm-context-offset ST
    SP CTX context-callstack-save-offset ST
    SP CTX context-callstack-bottom-offset LD
    load-stacks
    f IP load-address rel-word IP JSR
    SP CTX context-callstack-save-offset LD
    RA SP 52 LD CTX SP 56 LD CTX VM vm-context-offset ST
    R30 SP 48 LD
    12 <iota> [ 14 + int-register boa SP rot 4 * LD ] each-index
    SP SP 128 ADDUI RET ;
[ f jit-callback-stub ] CALLBACK-STUB jit-define
[ t jit-callback-stub ] make-jit-no-params
CALLBACK-STUB special-objects get at swap suffix
CALLBACK-STUB special-objects get set-at

[ f temp load-address rel-untagged temp DS temp ADDU obj temp 0 LD ] PIC-LOAD jit-define
[ type obj tag-mask get ANDI temp2 type MV ] PIC-TAG jit-define
[
    type obj tag-mask get ANDI temp tuple type-number LI
    [ type temp rot BNE ] [ type obj tuple-class-offset LW ] jit-conditional*
] PIC-TUPLE jit-define
[ f temp load-address rel-untagged temp2 type temp XOR ] PIC-CHECK-TAG jit-define
[ f temp load-address rel-literal temp2 type temp XOR ] PIC-CHECK-TUPLE jit-define
[ [ temp2 ZERO rot BNE ] [ f word-jump ] jit-conditional* ] PIC-HIT jit-define
[ PIC-TAIL RA MV f word-jump ] PIC-MISS-JUMP jit-define
[ f word-jump ] PIC-MISS-TAIL-JUMP jit-define
[
    type obj tag-mask get ANDI type type tag-bits get SLLI
    temp tuple type-number tag-fixnum LI
    [ type temp rot BNE ] [ type obj tuple-class-offset LW ] jit-conditional*
    f cache load-address rel-literal
    temp type mega-cache-size get 1 - bootstrap-cells ANDI
    cache cache temp ADD temp cache array-start-offset LW
    [ type temp rot BNE ] [
        temp2 native-address rel-megamorphic-cache-hits
        temp temp2 0 LD temp temp 1 ADDUI temp temp2 0 ST
        temp cache array-start-offset bootstrap-cell + LW
        temp temp word-entry-point-offset LW temp JMP
    ] jit-conditional*
] MEGA-LOOKUP jit-define

[ arg1 pop-ds temp arg1 quot-entry-point-offset LW ]
[ temp JSR ] [ temp JMP ] \ (call) define-combinator-primitive
[ temp pop-ds temp temp word-entry-point-offset LW ]
[ temp JSR ] [ temp JMP ] \ (execute) define-combinator-primitive
[ save-context arg2 VM MV "lazy_jit_compile" native-call*
  temp RETURN quot-entry-point-offset LW ]
[ temp JSR ] [ temp JMP ] \ lazy-jit-compile define-combinator-primitive
[ save-context arg1 SP 4 LD arg2 VM MV IP native-address rel-inline-cache-miss
  TRAMPOLINE JSR load-stacks ]
[ RETURN JSR ] [ RETURN JMP ] \ inline-cache-miss define-combinator-primitive
[ save-context arg1 PIC-TAIL MV arg2 VM MV IP native-address rel-inline-cache-miss
  TRAMPOLINE JSR load-stacks ]
[ RETURN JSR ] [ RETURN JMP ] \ inline-cache-miss-tail define-combinator-primitive

:: jit-compare ( branch -- )
    ds-0 DS 0 LW ds-1 DS -4 LW DS DS -4 ADDI
    t temp load-address rel-literal temp1 \ f type-number LI
    ds-1 ds-0 8 branch call temp1 temp MV temp1 DS 0 SW ; inline

{
    { c-to-factor [
        arg2 arg1 MV arg1 VM MV "begin_callback" native-call*
        temp RETURN quot-entry-point-offset LW temp JSR
        arg1 VM MV "end_callback" native-call
    ] }
    { inline-cache-miss-resume [
        prolog save-context arg1 PIC-TAIL MV arg2 VM MV
        IP native-address rel-inline-cache-miss TRAMPOLINE JSR
        load-stacks epilog RETURN JMP
    ] }
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
        ds-0 ZERO 8 BNE temp1 temp MV temp1 DS 0 SW
    ] }
    { fixnum+fast [ ds-0 DS 0 LW ds-1 DS -4 LW DS DS -4 ADDI ds-0 ds-1 ds-0 ADD ds-0 DS 0 SW ] }
    { fixnum-fast [ ds-0 DS 0 LW ds-1 DS -4 LW DS DS -4 ADDI ds-0 ds-1 ds-0 SUB ds-0 DS 0 SW ] }
    { fixnum-bitand [ ds-0 DS 0 LW ds-1 DS -4 LW DS DS -4 ADDI ds-0 ds-1 ds-0 AND ds-0 DS 0 SW ] }
    { fixnum-bitor [ ds-0 DS 0 LW ds-1 DS -4 LW DS DS -4 ADDI ds-0 ds-1 ds-0 OR ds-0 DS 0 SW ] }
    { fixnum-bitxor [ ds-0 DS 0 LW ds-1 DS -4 LW DS DS -4 ADDI ds-0 ds-1 ds-0 XOR ds-0 DS 0 SW ] }
    { string-nth-fast [
        ds-0 DS 0 LW ds-1 DS -4 LW DS DS -4 ADDI
        ds-1 ds-1 tag-bits get SRAI temp ds-0 ds-1 ADD
        ds-0 temp string-offset LBU ds-0 ds-0 tag-bits get SLLI ds-0 DS 0 SW
    ] }
    { slot [
        ds-0 DS 0 LW ds-1 DS -4 LW DS DS -4 ADDI
        ds-0 ds-0 tag-bits get 2 - SRAI ds-1 ds-1 tag-mask get bitnot ANDI
        temp ds-1 ds-0 ADD ds-0 temp 0 LW ds-0 DS 0 SW
    ] }
    { fixnum-bitnot [ ds-0 DS 0 LW ds-0 ds-0 tag-mask get bitnot XORI ds-0 DS 0 SW ] }
    { fixnum*fast [ ds-0 DS 0 LW ds-1 DS -4 LW DS DS -4 ADDI
        ds-0 ds-0 tag-bits get SRAI ds-0 ds-1 ds-0 MUL ds-0 DS 0 SW ] }
    { fixnum-shift-fast [
        ds-0 DS 0 LW ds-1 DS -4 LW DS DS -4 ADDI
        ds-0 ds-0 tag-bits get SRAI temp 31 LI
        temp2 ds-0 temp AND temp1 ds-1 temp2 MAK
        [ ds-0 ZERO rot BGE ] [
            ds-0 ds-0 NEG temp2 ds-0 temp AND
            temp1 ds-1 temp2 EXT temp1 temp1 tag-mask get bitnot ANDI
        ] jit-conditional*
        temp1 DS 0 SW
    ] }
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
        arg1 arg1 tag-bits get SRAI ds-0 arg1 arg2 mul-overflow ds-0 DS 0 SW
        [ 0 temp2 rot BB0 ] [
            arg2 arg2 tag-bits get SRAI arg3 VM MV "overflow_fixnum_multiply" native-call*
        ] jit-conditional*
    ] }
    { fixnum/i-fast [ save-context arg1 VM MV "primitive_fixnum_divint" native-call* ] }
    { fixnum/mod-fast [ save-context arg1 VM MV "primitive_fixnum_divmod" native-call* ] }
    { fixnum-mod [ save-context arg1 VM MV "primitive_fixnum_divmod" native-call*
        ds-0 pop-ds ds-0 DS 0 ST ] }
} define-sub-primitives
