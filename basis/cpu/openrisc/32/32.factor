! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.data arrays assocs byte-arrays
classes.algebra combinators compiler.cfg compiler.cfg.comparisons
compiler.cfg.instructions compiler.cfg.intrinsics compiler.cfg.registers
compiler.cfg.stack-frame compiler.codegen.gc-maps compiler.codegen.labels
compiler.codegen.relocation compiler.constants cpu.architecture
cpu.openrisc.32.abi cpu.openrisc.32.assembler
cpu.openrisc.32.assembler.registers generalizations kernel layouts literals
locals math math.bitwise math.order memory namespaces sequences system ;
IN: cpu.openrisc.32

M: openrisc.32 machine-registers
    { { int-regs ${ R21 R23 R25 R27 R29 R31 } }
      { float-regs ${ F0 F1 F2 F3 } } } ;
M: openrisc.32 frame-reg FP ;
M: openrisc.32 gc-root-offset n>> spill-offset 16 + 4 /i ;
: simm16? ( n -- ? ) dup 16 >signed = ;
:: add-offset ( dst src offset -- )
    offset simm16? [ dst src offset ADDI ] [ temp offset LI32 dst src temp ADD ] if ;
:: memory-offset ( base offset scratch -- base' offset' )
    offset simm16? [ base offset ] [ scratch offset LI32 scratch base scratch ADD scratch 0 ] if ;
: loc>address ( loc -- base offset )
    [ ds-loc? DS RS ? ] [ n>> cells neg ] bi temp memory-offset ;

M: openrisc.32 %load-immediate LI ;
M: openrisc.32 %load-reference
    [ swap load-address rel-literal ] [ \ f type-number LI ] if* ;
M:: openrisc.32 %load-float ( dst value -- )
    temp 0 LI32 value alien.c-types:float <ref> rc-native-0 rel-binary-literal
    dst lo>> int-register boa temp 0 LWZ ;
M:: openrisc.32 %load-double ( dst value -- )
    temp 0 LI32 value double <ref> rc-native-0 rel-binary-literal
    dst lo>> int-register boa temp 0 LWZ dst hi>> int-register boa temp 4 LWZ ;
M: openrisc.32 %peek loc>address LWZ ;
M: openrisc.32 %replace loc>address SW ;
M:: openrisc.32 %replace-imm ( src loc -- )
    temp2 src [ tag-fixnum ] [ \ f type-number ] if* LI temp2 loc %replace ;
M: openrisc.32 %clear [ 297 ] dip %replace-imm ;
M: openrisc.32 %inc [ ds-loc? DS RS ? dup ] [ n>> cells ] bi add-offset ;
M: openrisc.32 stack-frame-size (stack-frame-size) 16 + 16 align ;
M: openrisc.32 %call
    R11 load-address rel-word-pic R11 JALR NOP ;
:: load-current-address ( dst offset -- )
    temp1 RA MV 8 JAL NOP dst RA offset ADDI RA temp1 MV ;
M: openrisc.32 %jump
    PIC-TAIL 24 load-current-address
    R11 load-address rel-word-pic-tail R11 JR NOP ;
: jump-label ( label -- ) IP0 load-address label-fixup IP0 JR NOP ;
M: openrisc.32 %jump-label jump-label ;
M: openrisc.32 %return RET ;
M:: openrisc.32 %dispatch ( src scratch -- )
    scratch 24 load-current-address scratch scratch src ADD
    scratch scratch 0 LWZ scratch JR NOP ;
M: openrisc.32 %slot 2drop [ temp ] 2dip ADD temp 0 LWZ ;
M: openrisc.32 %slot-imm slot-offset temp memory-offset LWZ ;
M: openrisc.32 %set-slot 2drop [ temp ] 2dip ADD temp 0 SW ;
M: openrisc.32 %set-slot-imm slot-offset temp memory-offset SW ;
M: openrisc.32 %add ADD ;
M: openrisc.32 %add-imm add-offset ;
M: openrisc.32 %sub SUB ;
M: openrisc.32 %sub-imm neg add-offset ;
M: openrisc.32 %mul MUL ;
M:: openrisc.32 %mneg ( dst a b -- ) dst a b MUL dst dst NEG ;
M:: openrisc.32 %mul-imm ( dst src value -- ) temp value LI dst src temp MUL ;
M: openrisc.32 %and AND ;
M:: openrisc.32 %and-imm ( dst src value -- )
    value 16 bits value = [ dst src value ANDI ] [ temp value LI32 dst src temp AND ] if ;
M: openrisc.32 %or OR ;
M:: openrisc.32 %or-imm ( dst src value -- )
    value 16 bits value = [ dst src value ORI ] [ temp value LI32 dst src temp OR ] if ;
M: openrisc.32 %xor XOR ;
M:: openrisc.32 %xor-imm ( dst src value -- )
    value 16 bits value = [ dst src value XORI ] [ temp value LI32 dst src temp XOR ] if ;
M: openrisc.32 %shl SLL ;
M: openrisc.32 %shl-imm SLLI ;
M: openrisc.32 %shr SRL ;
M: openrisc.32 %shr-imm SRLI ;
M: openrisc.32 %sar SRA ;
M: openrisc.32 %sar-imm SRAI ;
M: openrisc.32 %not NOT ;
M: openrisc.32 %neg NEG ;

! Conditional branches skip an absolute jump, avoiding their short range.
:: flag>bit ( dst -- )
    dst 0 LI32 16 BNF NOP dst 1 LI32 ;
:: branch-flag ( label true? -- )
    true? [ 24 BNF ] [ 24 BF ] if NOP label jump-label ;
:: integer-flag ( a b cc -- )
    cc order-cc {
        { cc< [ a b SFLTS ] } { cc<= [ a b SFLES ] }
        { cc> [ a b SFGTS ] } { cc>= [ a b SFGES ] }
        { cc= [ a b SFEQ ] } { cc/= [ a b SFNE ] }
        { t [ ZERO ZERO SFEQ ] } { f [ ZERO ZERO SFNE ] }
    } case ;
:: compare-bit ( dst a b cc -- ) a b cc integer-flag dst flag>bit ;
:: boolean-result ( dst bit -- )
    bit ZERO SFEQ dst \ f type-number LI32 16 BF NOP
    t dst load-address rel-literal ;
M:: openrisc.32 %compare ( dst a b cc scratch -- )
    scratch a b cc compare-bit dst scratch boolean-result ;
M:: openrisc.32 %compare-integer-imm ( dst src value cc scratch -- )
    temp value LI dst src temp cc scratch %compare ;
M: openrisc.32 %compare-imm
    [ [ tag-fixnum ] [ \ f type-number ] if* ] 2dip %compare-integer-imm ;
M:: openrisc.32 %compare-branch ( label a b cc -- )
    a b cc integer-flag label t branch-flag ;
M:: openrisc.32 %compare-integer-imm-branch ( label src value cc -- )
    temp value LI label src temp cc %compare-branch ;
M: openrisc.32 %compare-imm-branch
    [ [ tag-fixnum ] [ \ f type-number ] if* ] dip %compare-integer-imm-branch ;

M:: openrisc.32 %min ( dst a b -- )
    <label> :> use-a <label> :> done
    a b SFLTS use-a t branch-flag dst b MV done jump-label
    use-a resolve-label dst a MV done resolve-label ;
M:: openrisc.32 %max ( dst a b -- )
    <label> :> use-a <label> :> done
    a b SFGTS use-a t branch-flag dst b MV done jump-label
    use-a resolve-label dst a MV done resolve-label ;

:: overflow-branch ( label cc -- )
    temp2 ZERO SFNE label cc cc/o eq? not branch-flag ;
M:: openrisc.32 %fixnum-add ( label dst a b cc -- )
    temp a b XOR
    temp2 a MV
    dst a b ADD
    temp2 temp2 dst XOR
    temp temp NOT
    temp temp temp2 AND
    temp2 temp 31 SRAI
    label cc overflow-branch ;
M:: openrisc.32 %fixnum-sub ( label dst a b cc -- )
    temp a b XOR
    temp2 a MV
    dst a b SUB
    temp2 temp2 dst XOR
    temp temp temp2 AND
    temp2 temp 31 SRAI
    label cc overflow-branch ;
:: multiply-overflow-flag ( dst a b -- )
    <label> :> zero <label> :> negative-one <label> :> done
    temp a MV
    temp2 b MV
    dst temp temp2 MUL
    temp2 ZERO SFEQ zero t branch-flag
    temp1 -1 LI
    temp2 temp1 SFEQ negative-one t branch-flag
    temp1 dst temp2 DIV
    temp1 temp SFNE done jump-label
    negative-one resolve-label
    ! Avoid the signed division overflow for INT_MIN / -1.
    temp dst SFEQ done f branch-flag
    temp ZERO SFNE done jump-label
    zero resolve-label
    ZERO ZERO SFNE
    done resolve-label ;
M:: openrisc.32 %fixnum-mul ( label dst a b cc -- )
    dst a b multiply-overflow-flag
    label cc cc/o eq? not branch-flag ;

M: openrisc.32 %add-float FADD.D ;
M: openrisc.32 %sub-float FSUB.D ;
M: openrisc.32 %mul-float FMUL.D ;
M: openrisc.32 %div-float FDIV.D ;
M:: openrisc.32 %integer>float ( dst src -- )
    temp2 src MV temp src 31 SRAI dst fp-conversion-temp ITOF.D ;
M:: openrisc.32 %float>integer ( dst src -- )
    fp-conversion-temp src FTOI.D dst temp2 MV ;
! These pure helpers cannot GC, but the allocator does not see their C calls.
! Preserve every allocatable GPR backing an integer or floating-point value.
CONSTANT: float-conversion-frame-size 64
CONSTANT: float-conversion-registers { 3 4 5 6 7 8 11 12 21 23 25 27 29 31 9 }
:: save-float-conversion-registers ( -- )
    SP SP float-conversion-frame-size neg ADDI
    float-conversion-registers
    [| reg-number n | reg-number int-register boa SP n 4 * SW ] each-index ;
:: restore-float-conversion-registers ( -- )
    float-conversion-registers
    [| reg-number n | reg-number int-register boa SP n 4 * LWZ ] each-index
    SP SP float-conversion-frame-size ADDI ;
:: call-float-conversion ( symbol -- )
    symbol f IP0 load-address rel-dlsym IP0 JALR NOP ;
M:: openrisc.32 %single>double-float ( dst src -- )
    save-float-conversion-registers
    arg1 src lo>> int-register boa MV
    "openrisc_single_to_double" call-float-conversion
    temp R11 MV
    temp2 R12 MV
    restore-float-conversion-registers
    dst lo>> int-register boa temp MV
    dst hi>> int-register boa temp2 MV ;
M:: openrisc.32 %double>single-float ( dst src -- )
    save-float-conversion-registers
    arg1 src lo>> int-register boa MV
    arg2 src hi>> int-register boa MV
    "openrisc_double_to_single" call-float-conversion
    temp R11 MV
    restore-float-conversion-registers
    dst lo>> int-register boa temp MV ;
: invert-flag ( -- ) temp flag>bit temp ZERO SFEQ ;
: negated-float-cc? ( cc -- ? )
    { cc/< cc/<= cc/> cc/>= cc/= cc/<> cc/<>= } member? ;
:: float-flag ( a b cc -- )
    cc {
        { cc< [ a b FSLT.D ] } { cc<= [ a b FSLE.D ] }
        { cc> [ a b FSGT.D ] } { cc>= [ a b FSGE.D ] }
        { cc= [ a b FSEQ.D ] } { cc/= [ a b FSEQ.D invert-flag ] }
        { cc<> [ a b FSUEQ.D invert-flag ] }
        { cc<>= [ a b FSUN.D invert-flag ] }
        { cc/< [ a b FSLT.D invert-flag ] }
        { cc/<= [ a b FSLE.D invert-flag ] }
        { cc/> [ a b FSGT.D invert-flag ] }
        { cc/>= [ a b FSGE.D invert-flag ] }
        { cc/<> [ a b FSUEQ.D ] } { cc/<>= [ a b FSUN.D ] }
    } case ;
:: quiet-float-flag ( a b cc -- )
    <label> :> ordered <label> :> done
    a b FSUN.D ordered f branch-flag
    cc negated-float-cc? [ ZERO ZERO SFEQ ] [ ZERO ZERO SFNE ] if
    done jump-label
    ordered resolve-label a b cc float-flag done resolve-label ;
M:: openrisc.32 %compare-float-ordered ( dst a b cc scratch -- )
    a b cc float-flag scratch flag>bit dst scratch boolean-result ;
M:: openrisc.32 %compare-float-unordered ( dst a b cc scratch -- )
    a b cc quiet-float-flag scratch flag>bit dst scratch boolean-result ;
M:: openrisc.32 %compare-float-ordered-branch ( label a b cc -- )
    a b cc float-flag label t branch-flag ;
M:: openrisc.32 %compare-float-unordered-branch ( label a b cc -- )
    a b cc quiet-float-flag label t branch-flag ;
M:: openrisc.32 %min-float ( dst a b -- )
    <label> :> use-a <label> :> done a b FSLT.D use-a t branch-flag
    dst lo>> int-register boa b lo>> int-register boa MV
    dst hi>> int-register boa b hi>> int-register boa MV done jump-label
    use-a resolve-label dst lo>> int-register boa a lo>> int-register boa MV
    dst hi>> int-register boa a hi>> int-register boa MV done resolve-label ;
M:: openrisc.32 %max-float ( dst a b -- )
    <label> :> use-a <label> :> done a b FSGT.D use-a t branch-flag
    dst lo>> int-register boa b lo>> int-register boa MV
    dst hi>> int-register boa b hi>> int-register boa MV done jump-label
    use-a resolve-label dst lo>> int-register boa a lo>> int-register boa MV
    dst hi>> int-register boa a hi>> int-register boa MV done resolve-label ;

:: fp-load ( reg base offset rep -- )
    base offset temp memory-offset :> ( addr disp )
    reg lo>> int-register boa addr disp LWZ
    rep double-rep eq? [ reg hi>> int-register boa addr disp 4 + LWZ ] when ;
:: fp-store ( reg base offset rep -- )
    base offset temp memory-offset :> ( addr disp )
    reg lo>> int-register boa addr disp SW
    rep double-rep eq? [ reg hi>> int-register boa addr disp 4 + SW ] when ;
:: copy-register ( dst src rep -- )
    rep { float-rep double-rep } member? [
        dst lo>> int-register boa src lo>> int-register boa MV
        rep double-rep eq? [ dst hi>> int-register boa src hi>> int-register boa MV ] when
    ] [ dst src MV ] if ;
M:: openrisc.32 %copy ( dst src rep -- )
    dst src eq? [ ] [
        dst spill-slot? [
            src spill-slot? [
                rep { float-rep double-rep } member? fp-temp temp2 ? :> scratch
                rep { float-rep double-rep } member? [
                    scratch SP src n>> spill-offset rep fp-load
                    scratch SP dst n>> spill-offset rep fp-store
                ] [
                    scratch SP src n>> spill-offset LWZ
                    scratch SP dst n>> spill-offset SW
                ] if
            ] [
                rep { float-rep double-rep } member?
                [ src SP dst n>> spill-offset rep fp-store ]
                [ src SP dst n>> spill-offset SW ] if
            ] if
        ] [
            src spill-slot? [
                rep { float-rep double-rep } member?
                [ dst SP src n>> spill-offset rep fp-load ]
                [ dst SP src n>> spill-offset LWZ ] if
            ]
            [ dst src rep copy-register ] if
        ] if
    ] if ;
M: openrisc.32 %spill -rot %copy ;
M: openrisc.32 %reload swap %copy ;

UNION: integer-rep int-rep tagged-rep ;
:: load-memory ( dst base offset rep c-type -- )
    base offset temp memory-offset :> ( addr disp )
    c-type rep integer-rep? and [
        c-type heap-size {
            { 1 [ c-type c-type-signed [ dst addr disp LBS ] [ dst addr disp LBZ ] if ] }
            { 2 [ c-type c-type-signed [ dst addr disp LHS ] [ dst addr disp LHZ ] if ] }
            { 4 [ dst addr disp LWZ ] }
            { 8 [ dst addr disp LWZ ] }
        } case
    ] [ rep integer-rep? [ dst addr disp LWZ ] [ dst addr disp rep fp-load ] if ] if ;
:: store-memory ( src base offset rep c-type -- )
    base offset temp memory-offset :> ( addr disp )
    c-type rep integer-rep? and [ c-type heap-size {
        { 1 [ src addr disp SB ] } { 2 [ src addr disp SH ] }
        { 4 [ src addr disp SW ] } { 8 [ src addr disp SW ] }
    } case ] [ rep integer-rep? [ src addr disp SW ] [ src addr disp rep fp-store ] if ] if ;
M: openrisc.32 %load-memory-imm load-memory ;
M: openrisc.32 %store-memory-imm store-memory ;
M:: openrisc.32 %load-memory ( dst base index scale offset rep c-type -- )
    temp2 index scale SLLI temp2 base temp2 ADD
    dst temp2 offset rep c-type load-memory ;
M:: openrisc.32 %store-memory ( src base index scale offset rep c-type -- )
    temp2 index scale SLLI temp2 base temp2 ADD
    src temp2 offset rep c-type store-memory ;
M:: openrisc.32 %convert-integer ( dst src c-type -- )
    32 c-type heap-size 8 * - :> count
    count zero? [ dst src MV ] [ dst src count SLLI
        c-type c-type-signed [ dst dst count SRAI ] [ dst dst count SRLI ] if
    ] if ;
M:: openrisc.32 %alien-global ( dst symbol library -- )
    symbol library dst load-address rel-dlsym ;
M: openrisc.32 %vm-field [ VM ] dip temp memory-offset LWZ ;
M: openrisc.32 %set-vm-field [ VM ] dip temp memory-offset SW ;
M: openrisc.32 %unbox-alien alien-offset LWZ ;
M:: openrisc.32 %unbox-any-c-ptr ( dst src -- )
    <label> :> done <label> :> not-f <label> :> not-alien
    temp2 \ f type-number LI src temp2 SFEQ not-f f branch-flag
    dst ZERO MV done jump-label
    not-f resolve-label temp src tag-mask get ANDI temp2 alien type-number LI
    temp temp2 SFEQ not-alien f branch-flag
    dst src alien-offset LWZ done jump-label
    not-alien resolve-label dst src byte-array-offset add-offset done resolve-label ;
M:: openrisc.32 %allot ( dst size class scratch -- )
    dst VM vm-nursery-here-offset LWZ
    temp2 dst size data-alignment get align add-offset
    temp2 VM vm-nursery-here-offset SW
    temp class type-number tag-header LI temp dst 0 SW
    dst dst class type-number ADDI ;
:: alien-store ( src dst n -- ) src dst n cells alien type-number - SW ;
M:: openrisc.32 %box-alien ( dst src scratch -- )
    temp1 src MV
    <label> :> done
    dst \ f type-number LI temp1 ZERO SFEQ done t branch-flag
    dst 5 cells alien scratch %allot temp \ f type-number LI
    temp dst 1 alien-store temp dst 2 alien-store
    temp1 dst 3 alien-store temp1 dst 4 alien-store done resolve-label ;
M:: openrisc.32 %box-displaced-alien ( dst disp base scratch base-class -- )
    temp1 base MV
    scratch disp MV
    <label> :> done <label> :> not-f <label> :> not-alien
    dst temp1 MV
    scratch ZERO SFEQ done t branch-flag
    dst 5 cells alien scratch %allot
    temp \ f type-number LI
    temp dst 2 alien-store
    temp2 \ f type-number LI
    temp1 temp2 SFEQ not-f f branch-flag
    temp dst 1 alien-store
    scratch dst 3 alien-store
    scratch dst 4 alien-store
    done jump-label
    not-f resolve-label
    temp temp1 tag-mask get ANDI
    temp2 alien type-number LI
    temp temp2 SFEQ not-alien f branch-flag
    temp temp1 1 cells alien type-number - LWZ
    temp dst 1 alien-store
    temp temp1 2 cells alien type-number - LWZ
    temp dst 2 alien-store
    temp temp1 3 cells alien type-number - LWZ
    temp temp scratch ADD
    temp dst 3 alien-store
    temp temp1 4 cells alien type-number - LWZ
    temp temp scratch ADD
    temp dst 4 alien-store
    done jump-label
    not-alien resolve-label
    temp1 dst 1 alien-store
    scratch dst 3 alien-store
    temp temp1 scratch ADD
    temp temp byte-array-offset add-offset
    temp dst 4 alien-store
    done resolve-label ;
:: write-barrier ( card scratch -- )
    temp card-mark LI card card card-bits SRLI
    scratch VM vm-cards-offset-offset LWZ scratch scratch card ADD temp scratch 0 SB
    card card deck-bits card-bits - SRLI
    scratch VM vm-decks-offset-offset LWZ scratch scratch card ADD temp scratch 0 SB ;
M:: openrisc.32 %write-barrier ( src slot scale tag card scratch -- )
    card src slot ADD card scratch write-barrier ;
M:: openrisc.32 %write-barrier-imm ( src slot tag card scratch -- )
    card src slot tag slot-offset add-offset card scratch write-barrier ;
M:: openrisc.32 %check-nursery-branch ( label size cc scratch1 scratch2 -- )
    scratch1 VM vm-nursery-here-offset LWZ scratch1 scratch1 size add-offset
    scratch2 VM vm-nursery-end-offset LWZ
    scratch1 scratch2 SFGTU label cc cc<= eq? not branch-flag ;
M: openrisc.32 %call-gc \ minor-gc %call gc-map-here ;
M:: openrisc.32 %local-allot ( dst size align offset -- )
    dst SP offset local-allot-offset add-offset ;
M:: openrisc.32 %save-context ( scratch1 scratch2 -- )
    FP CTX context-callstack-top-offset SW
    DS CTX context-datastack-offset SW RS CTX context-retainstack-offset SW ;
: return-reg ( rep -- reg ) reg-class-of return-regs at first ;
: load-reg-param ( vreg rep reg -- ) swap %copy ;
: store-reg-param ( vreg rep reg -- ) -rot %copy ;
M:: openrisc.32 %unbox ( dst src func rep -- )
    arg1 src tagged-rep %copy
    arg2 VM MV
    func f f %c-invoke
    dst rep rep return-reg load-reg-param ;
M:: openrisc.32 %box ( dst src func rep gc-map -- )
    rep reg-class-of f param-regs at first src rep %copy
    ! The VM follows one GPR for a single or two GPRs for a double.
    rep double-rep eq? arg3 arg2 ? VM MV
    func f gc-map %c-invoke
    dst int-rep R11 load-reg-param ;
M:: openrisc.32 %unbox-long-long ( hi lo src func -- )
    arg1 src tagged-rep %copy
    arg2 VM MV
    func f f %c-invoke
    hi R11 int-rep %copy
    lo R12 int-rep %copy ;
M:: openrisc.32 %box-long-long ( dst hi lo func gc-map -- )
    arg1 hi int-rep %copy
    arg2 lo int-rep %copy
    arg3 VM MV
    func f gc-map %c-invoke
    dst R11 tagged-rep %copy ;
M:: openrisc.32 %c-invoke ( symbol dll gc-map -- )
    symbol dll IP0 load-address rel-dlsym TRAMPOLINE JALR NOP gc-map gc-map-here ;
:: stack-call-gc-map ( gc-map size -- gc-map' )
    gc-map dup gc-map-needed? [
        [ clone [ size - ] change-n ] :> shift-slot clone
        [ shift-slot map ] change-gc-roots
        [ [ shift-slot bi@ ] assoc-map ] change-derived-roots
    ] when ;
:: c-invoke-stack ( size symbol dll gc-map -- )
    IP1 SP size 16 - add-offset symbol dll IP0 load-address rel-dlsym
    TRAMPOLINE2 JALR NOP gc-map size stack-call-gc-map gc-map-here ;
M: openrisc.32 %alien-invoke
    reach [ '[ _ _ _ %c-invoke ] ] [ -roll '[ _ _ _ _ c-invoke-stack ] ]
    if-zero %alien-assembly ;
: ?spill-slot ( obj -- reg )
    dup spill-slot? [ n>> spill-offset SP swap temp memory-offset temp2 -rot LWZ temp2 ] when ;
:: c-indirect-stack ( size src gc-map -- )
    IP1 SP size 16 - add-offset IP0 src ?spill-slot MV
    TRAMPOLINE2 JALR NOP gc-map size stack-call-gc-map gc-map-here ;
M: openrisc.32 %alien-indirect
    [ 8 nrot ] dip pick [ '[
        IP0 _ ?spill-slot MV TRAMPOLINE JALR NOP _ gc-map-here
    ] ] [ -rot '[ _ _ _ c-indirect-stack ] ] if-zero %alien-assembly ;
:: store-stack-param ( vreg rep offset size -- )
    vreg spill-slot? [
        ! F0 is allocatable, so a temporary FP copy could destroy another
        ! argument. Transfer spilled payloads through the reserved GPR.
        rep rep-size cell /i [| word |
            temp2 SP vreg n>> spill-offset word cells + LWZ
            temp2 SP offset word cells + SW
        ] each-integer
    ] [ vreg SP offset rep f store-memory ] if ;
M:: openrisc.32 %alien-assembly ( varargs? reg-inputs stack-inputs
    reg-outputs dead-outputs cleanup stack-size quot -- )
    stack-inputs [ first4 store-stack-param ] each
    reg-inputs [ first3 store-reg-param ] each
    quot call( -- )
    reg-outputs [ first3 load-reg-param ] each ;
! The callback stub reserves 64 bytes before its incoming stack arguments.
! Keep this offset in sync with bootstrap.assembler.openrisc.32.
:: load-stack-param ( vreg rep offset size -- )
    temp2 CTX context-callstack-save-offset LWZ
    vreg spill-slot? [
        rep integer-rep? IP0 fp-temp ? :> scratch
        scratch temp2 offset 64 + rep f load-memory vreg scratch rep %copy
    ] [ vreg temp2 offset 64 + rep f load-memory ] if ;
M: openrisc.32 %callback-inputs
    [ [ first3 load-reg-param ] each ] [ [ first4 load-stack-param ] each ] bi*
    arg1 VM MV arg2 ZERO MV "begin_callback" f f %c-invoke ;
M: openrisc.32 %callback-stack
    dup CTX context-callstack-save-offset LWZ dup 64 ADDI ;
M: openrisc.32 %callback-outputs
    arg1 VM MV "end_callback" f f %c-invoke [ first3 store-reg-param ] each ;

M: openrisc.32 %prologue
    SP SP -16 ADDI
    FP SP 0 SW
    RA SP 4 SW
    FP SP MV
    16 - neg SP SP rot add-offset ;
M: openrisc.32 %epilogue
    16 - SP SP rot add-offset
    FP SP 0 LWZ
    RA SP 4 LWZ
    SP SP 16 ADDI ;
M: openrisc.32 %safepoint SAFEPOINT SAFEPOINT 0 SW ;
M: openrisc.32 complex-addressing? f ;
M: openrisc.32 integer-float-needs-stack-frame? f ;
M: openrisc.32 fused-unboxing? t ;
M: openrisc.32 immediate-arithmetic? simm16? ;
M: openrisc.32 immediate-bitwise? dup 16 bits = ;
M: openrisc.32 immediate-comparand?
    dup fixnum? [ simm16? ] [ not ] if ;
M: openrisc.32 immediate-store? drop f ;
M: openrisc.32 enable-cpu-features
    enable-float-intrinsics enable-float-min/max enable-min/max ;
