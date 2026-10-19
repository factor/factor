! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.data arrays assocs
classes.struct combinators compiler.cfg compiler.cfg.comparisons
compiler.cfg.instructions compiler.cfg.intrinsics compiler.cfg.registers
compiler.cfg.stack-frame compiler.codegen.gc-maps compiler.codegen.labels
compiler.codegen.relocation compiler.constants cpu.architecture
cpu.sparc.assembler kernel layouts literals locals make math
math.bitwise math.order memory namespaces sequences system vm ;
QUALIFIED-WITH: alien.c-types c
IN: cpu.sparc

! Globals survive register window rotation. g1/l7 are reserved temporaries.
! The allocator uses only the current window's locals and incoming registers.
CONSTANT: ds-reg 2
CONSTANT: rs-reg 3
CONSTANT: vm-reg 4
CONSTANT: scratch-reg 1
CONSTANT: scratch2-reg 23
CONSTANT: fp-scratch-reg 30
CONSTANT: sp-reg 14

M: sparc machine-registers
    { { int-regs { 16 17 18 19 24 25 26 27 28 29 } }
      { float-regs { 0 2 4 6 8 10 12 14 16 18 20 22 24 26 28 } } } ;
M: sparc frame-reg 30 ;
M: sparc register-window-frame-required? t ;
M: sparc complex-addressing? f ;
M: sparc vm-stack-space 0 ;

HOOK: stack-bias cpu ( -- n )
M: sparc.32 stack-bias 0 ;
M: sparc.64 stack-bias 2047 ;
HOOK: %cell-load cpu ( dst base offset -- )
HOOK: %cell-store cpu ( src base offset -- )
HOOK: %cell-load-x cpu ( dst base index -- )
HOOK: %cell-store-x cpu ( src base index -- )
M: sparc.32 %cell-load-x LDR ;
M: sparc.64 %cell-load-x LDXR ;
M: sparc.32 %cell-store-x STR ;
M: sparc.64 %cell-store-x STXR ;
HOOK: %set-cell cpu ( dst value -- )
M: sparc.32 %set-cell 32 bits SET32 ;
M: sparc.64 %set-cell
    [ dup scratch2-reg = scratch-reg scratch2-reg ? ] dip 64 bits SET64 ;

M: sparc %load-immediate
    dup -4096 4095 between? [ [ 0 ] dip ORI ] [ %set-cell ] if ;
! Large frames and SP-biased spill addresses exceed simm13.
:: memory-address ( base offset -- base' offset' )
    offset -4096 4095 between? [ base offset ] [
        22 base int-rep %copy
        scratch2-reg offset %load-immediate
        22 22 scratch2-reg ADD 22 0
    ] if ;
:: store-address ( src base offset -- src' base' offset' )
    offset -4096 4095 between? [ src base offset ] [
        22 base int-rep %copy 21 src int-rep %copy
        22 offset memory-address 21 -rot
    ] if ;
M:: sparc.32 %cell-load ( dst base offset -- )
    base offset memory-address dst -rot LD ;
M:: sparc.64 %cell-load ( dst base offset -- )
    base offset memory-address dst -rot LDX ;
M: sparc.32 %cell-store store-address ST ;
M: sparc.64 %cell-store store-address STX ;
:: float-load ( dst base offset rep -- )
    base offset memory-address :> ( address displacement )
    rep float-rep = [ dst address displacement LDF ] [ dst address displacement LDDF ] if ;
:: float-store ( src base offset rep -- )
    base offset memory-address :> ( address displacement )
    rep float-rep = [ src address displacement STF ] [ src address displacement STDF ] if ;

M: sparc %load-reference
    [ [ 0 %set-cell ] dip rc-native-1 rel-literal ]
    [ \ f type-number %load-immediate ] if* ;
M:: sparc %load-float ( dst val -- )
    scratch-reg 0 %set-cell val c:float <ref> rc-native-1 rel-binary-literal
    dst scratch-reg 0 LDF ;
M:: sparc %load-double ( dst val -- )
    scratch-reg 0 %set-cell val double <ref> rc-native-1 rel-binary-literal
    dst scratch-reg 0 LDDF ;

: loc-reg ( loc -- reg ) ds-loc? ds-reg rs-reg ? ;
M: sparc %peek [ loc-reg ] [ n>> bootstrap-cells neg ] bi %cell-load ;
M: sparc %replace [ loc-reg ] [ n>> bootstrap-cells neg ] bi %cell-store ;
M:: sparc %replace-imm ( value loc -- )
    scratch-reg value dup fixnum? [ tag-fixnum %load-immediate ]
    [ %load-reference ] if scratch-reg loc %replace ;
M: sparc %clear 297 swap %replace-imm ;
M: sparc %inc [ loc-reg dup ] [ n>> bootstrap-cells ] bi ADDI ;

M: sparc %add ADD ;
M: sparc %add-imm ADDI ;
M: sparc %sub SUB ;
M: sparc %sub-imm SUBI ;
M: sparc.32 %mul SMUL ;
M: sparc.64 %mul MULX ;
M: sparc.32 %mul-imm SMULI ;
M: sparc.64 %mul-imm MULXI ;
M: sparc %and AND ;
M: sparc %and-imm ANDI ;
M: sparc %or OR ;
M: sparc %or-imm ORI ;
M: sparc %xor XOR ;
M: sparc %xor-imm XORI ;
M: sparc.32 %shl SLL ;
M: sparc.32 %shr SRL ;
M: sparc.32 %sar SRA ;
M: sparc.32 %shl-imm SLLI ;
M: sparc.32 %shr-imm SRLI ;
M: sparc.32 %sar-imm SRAI ;
M: sparc.64 %shl SLLX ;
M: sparc.64 %shr SRLX ;
M: sparc.64 %sar SRAX ;
M: sparc.64 %shl-imm SLLXI ;
M: sparc.64 %shr-imm SRLXI ;
M: sparc.64 %sar-imm SRAXI ;
M: sparc %not 0 XNORI ;
M: sparc %neg [ 0 ] dip SUB ;
HOOK: copy-double cpu ( dst src -- )
M:: sparc.32 copy-double ( dst src -- )
    ! V8 has single-register moves; FMOVD requires V9.
    dst src FMOVS dst 1 + src 1 + FMOVS ;
M: sparc.64 copy-double FMOVD ;
M: sparc %copy
    2over = [ 3drop ] [
        { { int-rep [ 0 ORI ] } { tagged-rep [ 0 ORI ] }
          { float-rep [ FMOVS ] } { double-rep [ copy-double ] } } case
    ] if ;
M: sparc %add-float FADDD ;
M: sparc %sub-float FSUBD ;
M: sparc %mul-float FMULD ;
M: sparc %div-float FDIVD ;
M: sparc %sqrt FSQRTD ;
M: sparc %single>double-float FSTOD ;
M: sparc %double>single-float FDTOS ;
M: sparc immediate-arithmetic? -4096 4095 between? ;
M: sparc immediate-bitwise? immediate-arithmetic? ;
M: sparc immediate-store? immediate-comparand? ;
M: sparc fused-unboxing? f ;
M: sparc enable-cpu-features enable-float-intrinsics ;

! Each branch has its own explicit delay slot, including conditional paths.
:: branch ( label condition -- )
    bootstrap-cell 8 = [ condition 0 2 t f BPcc ] [ condition 0 f Bicc ] if
    label rc-native-0 label-fixup NOP ;
M: sparc %jump-label 8 branch ;
:: branch-cc ( label cc -- )
    cc order-cc {
        { cc< [ label 3 branch ] } { cc<= [ label 2 branch ] }
        { cc> [ label 10 branch ] } { cc>= [ label 11 branch ] }
        { cc= [ label 1 branch ] } { cc/= [ label 9 branch ] }
    } case ;
M:: sparc %compare-branch ( label src1 src2 cc -- )
    0 src1 src2 SUBcc label cc branch-cc ;
M:: sparc %compare-integer-imm-branch ( label src1 src2 cc -- )
    0 src1 src2 SUBccI label cc branch-cc ;
: tagged-comparand ( value -- n ) [ tag-fixnum ] [ \ f type-number ] if* ;
M: sparc %compare-imm-branch [ tagged-comparand ] dip %compare-integer-imm-branch ;
:: boolean ( dst cc -- )
    <label> :> yes <label> :> end
    yes cc branch-cc dst \ f type-number %load-immediate
    end %jump-label yes resolve-label dst \ t %load-reference
    end resolve-label ;
M:: sparc %compare ( dst src1 src2 cc temp -- )
    0 src1 src2 SUBcc dst cc boolean ;
M:: sparc %compare-integer-imm ( dst src1 src2 cc temp -- )
    0 src1 src2 SUBccI dst cc boolean ;
M: sparc %compare-imm [ tagged-comparand ] 2dip %compare-integer-imm ;

M:: sparc %min ( dst src1 src2 -- )
    <label> :> end scratch2-reg src2 int-rep %copy
    0 src1 scratch2-reg SUBcc
    dst src1 int-rep %copy end cc<= branch-cc
    dst scratch2-reg int-rep %copy end resolve-label ;
M:: sparc %max ( dst src1 src2 -- )
    <label> :> end scratch2-reg src2 int-rep %copy
    0 src1 scratch2-reg SUBcc
    dst src1 int-rep %copy end cc>= branch-cc
    dst scratch2-reg int-rep %copy end resolve-label ;

M: sparc %slot [ 0 assert= ] bi@ %cell-load-x ;
M: sparc %set-slot [ 0 assert= ] bi@ %cell-store-x ;
M: sparc %slot-imm slot-offset %cell-load ;
M: sparc %set-slot-imm slot-offset %cell-store ;
M: sparc %vm-field [ vm-reg ] dip %cell-load ;
M: sparc %set-vm-field [ vm-reg ] dip %cell-store ;
M: sparc %unbox-alien alien-offset %cell-load ;
M:: sparc %unbox-any-c-ptr ( dst src -- )
    20 src int-rep %copy
    <label> :> end dst 0 %load-immediate
    0 20 \ f type-number SUBccI end cc= branch-cc
    scratch-reg 20 tag-mask get ANDI
    0 scratch-reg alien type-number SUBccI
    dst 20 byte-array-offset ADDI end cc/= branch-cc
    dst 20 alien-offset %cell-load end resolve-label ;

M:: sparc %allot ( dst size class temp -- )
    temp vm-reg vm-nursery-here-offset ADDI
    dst temp 0 %cell-load
    scratch-reg dst size data-alignment get align ADDI
    scratch-reg temp 0 %cell-store
    scratch-reg class type-number tag-header %load-immediate
    scratch-reg dst 0 %cell-store dst dst class type-number ORI ;

:: write-barrier ( temp1 temp2 -- )
    scratch-reg card-mark %load-immediate
    temp1 temp1 card-bits %shr-imm
    temp2 0 %set-cell rc-native-1 rel-cards-offset
    scratch-reg temp1 temp2 STBR
    temp1 temp1 deck-bits card-bits - %shr-imm
    temp2 0 %set-cell rc-native-1 rel-decks-offset
    scratch-reg temp1 temp2 STBR ;
M:: sparc %write-barrier ( src slot scale tag temp1 temp2 -- )
    scale 0 assert= tag 0 assert= temp1 src slot ADD
    temp1 temp2 write-barrier ;
M:: sparc %write-barrier-imm ( src slot tag temp1 temp2 -- )
    temp1 src slot tag slot-offset ADDI temp1 temp2 write-barrier ;

! The first sixteen bootstrap-cells belong to native register-window spills. The ABI
! outgoing save area follows. Factor spill/allot space starts after both.
: reserved-area ( -- n ) bootstrap-cell 8 = [ 176 ] [ 96 ] if ;
: spill@ ( n -- offset ) spill-offset reserved-area + stack-bias + ;
M: sparc gc-root-offset n>> spill-offset reserved-area + bootstrap-cell /i ;
M: sparc stack-frame-size (stack-frame-size) reserved-area + 16 align ;
! SAVE exposes the interrupted o7 as a caller-map return in the callee window.
M: sparc entry-safepoint-after-prologue? t ;
M:: sparc %prologue ( frame-size -- )
    frame-size 4096 >= [
        scratch-reg frame-size neg %load-immediate
        scratch-reg scratch-reg stack-bias ADDI
        0 sp-reg scratch-reg %cell-load-x
        scratch-reg scratch-reg stack-bias neg ADDI
        sp-reg sp-reg scratch-reg SAVE
    ] [
        0 sp-reg stack-bias frame-size - %cell-load
        sp-reg sp-reg frame-size neg SAVEI
    ] if ;
M:: sparc.64 %prologue ( frame-size -- )
    frame-size 4096 >= [
        ! No caller local/input register can be used before SAVE. Preserve
        ! outgoing argument six while using o5 to build the frame delta.
        13 sp-reg stack-bias 168 + %cell-store
        scratch-reg 13 frame-size neg 64 bits SET64
        13 sp-reg stack-bias 168 + %cell-load
        scratch-reg scratch-reg stack-bias ADDI
        0 sp-reg scratch-reg %cell-load-x
        scratch-reg scratch-reg stack-bias neg ADDI
        sp-reg sp-reg scratch-reg SAVE
    ] [
        0 sp-reg stack-bias frame-size - %cell-load
        sp-reg sp-reg frame-size neg SAVEI
    ] if ;
M: sparc %epilogue drop RESTORE0 ;
M: sparc %return RETL NOP ;
M: sparc %call
    [ scratch-reg 0 %set-cell ] dip rc-native-1 rel-word-pic
    15 scratch-reg 0 JMPLI NOP ;
M: sparc %jump
    ! Tail PIC misses patch this jump, while o7 remains the caller's return.
    ! CALL reads PC on V8 and V9; o4 carries the end of the jump template.
    13 15 0 ORI 8 CALL NOP
    12 15 bootstrap-cell 4 = [ 32 ] [ 48 ] if ADDI 15 13 0 ORI
    ! The epilogue already restored the caller's window. Use outgoing o5,
    ! since the ordinary %set-cell temporary l7 now belongs to the caller.
    [ bootstrap-cell 4 =
      [ scratch-reg 0 32 bits SET32 ]
      [ scratch-reg 13 0 64 bits SET64 ] if
    ] dip rc-native-1 rel-word-pic-tail
    0 scratch-reg 0 JMPLI NOP ;
M:: sparc %dispatch ( src temp -- )
    <label> :> table
    temp 0 %set-cell table rc-native-1 label-fixup
    temp temp src %cell-load-x 0 temp 0 JMPLI NOP
    bootstrap-cell align-code table resolve-label ;

M: sparc %spill
    n>> spill@ swap {
        { int-rep [ [ sp-reg ] dip %cell-store ] }
        { tagged-rep [ [ sp-reg ] dip %cell-store ] }
        { float-rep [ [ sp-reg ] dip float-rep float-store ] }
        { double-rep [ [ sp-reg ] dip double-rep float-store ] }
    } case ;
M: sparc %reload
    n>> spill@ swap {
        { int-rep [ [ sp-reg ] dip %cell-load ] }
        { tagged-rep [ [ sp-reg ] dip %cell-load ] }
        { float-rep [ [ sp-reg ] dip float-rep float-load ] }
        { double-rep [ [ sp-reg ] dip double-rep float-load ] }
    } case ;
M:: sparc %local-allot ( dst size align offset -- )
    offset local-allot-offset reserved-area + stack-bias + :> displacement
    displacement -4096 4095 between? [ dst sp-reg displacement ADDI ] [
        dst displacement %load-immediate dst sp-reg dst ADD
    ] if ;
M: sparc integer-float-needs-stack-frame? t ;
M:: sparc.32 %integer>float ( dst src -- )
    src sp-reg stack-bias 80 + ST dst sp-reg stack-bias 80 + LDF
    dst dst FITOD ;
M:: sparc.64 %integer>float ( dst src -- )
    src sp-reg stack-bias 128 + STX dst sp-reg stack-bias 128 + LDDF
    dst dst FXTOD ;
M:: sparc.32 %float>integer ( dst src -- )
    fp-scratch-reg src FDTOI
    fp-scratch-reg sp-reg stack-bias 80 + STF
    dst sp-reg stack-bias 80 + LD ;
M:: sparc.64 %float>integer ( dst src -- )
    fp-scratch-reg src FDTOX
    fp-scratch-reg sp-reg stack-bias 128 + STDF
    dst sp-reg stack-bias 128 + LDX ;

M:: sparc %check-nursery-branch ( label size cc temp1 temp2 -- )
    temp1 vm-reg vm-nursery-here-offset %cell-load
    temp2 vm-reg vm-nursery-end-offset %cell-load
    temp1 temp1 size ADDI 0 temp1 temp2 SUBcc
    ! This check compares addresses, hence unsigned conditions.
    cc cc<= = [ label 4 branch ] [ label 12 branch ] if ;
M: sparc %call-gc \ minor-gc %call gc-map-here ;

:: aligned-load-memory ( dst base offset rep type -- )
    base offset memory-address :> ( address displacement )
    type {
        { c:char [ dst address displacement LDSB ] }
        { c:uchar [ dst address displacement LDUB ] }
        { c:short [ dst address displacement LDSH ] }
        { c:ushort [ dst address displacement LDUH ] }
        { c:int [ dst address displacement LD dst dst 0 SRAI ] }
        { c:uint [ dst address displacement LD ] }
        [ drop rep {
            { int-rep [ dst address displacement %cell-load ] }
            { tagged-rep [ dst address displacement %cell-load ] }
            { float-rep [ dst address displacement LDF ] }
            { double-rep [ dst address displacement LDDF ] }
        } case ]
    } case ;
:: aligned-store-memory ( src base offset rep type -- )
    rep reg-class-of int-regs = [
        src base offset store-address
     ] [ base offset memory-address src -rot ] if :> ( source address displacement )
    type {
        { c:char [ source address displacement STB ] }
        { c:uchar [ source address displacement STB ] }
        { c:short [ source address displacement STH ] }
        { c:ushort [ source address displacement STH ] }
        { c:int [ source address displacement ST ] }
        { c:uint [ source address displacement ST ] }
        [ drop rep {
            { int-rep [ source address displacement %cell-store ] }
            { tagged-rep [ source address displacement %cell-store ] }
            { float-rep [ source address displacement STF ] }
            { double-rep [ source address displacement STDF ] }
        } case ]
    } case ;
! Alien accessors permit arbitrary byte offsets, as the VM's memcpy accessors do.
! l4-l7 are reserved scratch registers; allocator locals/incoming registers stay
! untouched. Fast cell, spill and GC operations use separate direct primitives.
:: memory-width ( rep type -- n )
    type {
        { c:char [ 1 ] } { c:uchar [ 1 ] }
        { c:short [ 2 ] } { c:ushort [ 2 ] }
        { c:int [ 4 ] } { c:uint [ 4 ] }
        [ drop rep { { float-rep [ 4 ] } { double-rep [ 8 ] }
                     [ drop bootstrap-cell ] } case ]
    } case ;
:: load-memory-bytes ( dst address offset count -- )
    21 0 0 ORI
    count <iota> [| index |
        21 21 8 %shl-imm 22 address offset index + LDUB
        21 21 22 OR
    ] each dst 21 int-rep %copy ;
:: store-memory-bytes ( src address offset count -- )
    21 src int-rep %copy
    count <iota> [| index |
        22 21 count index - 1 - 8 * %shr-imm
        22 address offset index + STB
    ] each ;
: memory-fp-scratch ( -- offset )
    bootstrap-cell 8 = 128 80 ? stack-bias + ;
:: unaligned-load-memory ( dst address rep type count -- )
    rep reg-class-of int-regs = [
        dst address 0 count load-memory-bytes
        type { c:char c:short c:int } member? count bootstrap-cell < and [
            bootstrap-cell count - 8 * :> shift
            dst dst shift %shl-imm dst dst shift %sar-imm
        ] when
    ] [
        rep double-rep = bootstrap-cell 4 = and [
            21 address 0 4 load-memory-bytes 21 sp-reg memory-fp-scratch ST
            21 address 4 4 load-memory-bytes 21 sp-reg memory-fp-scratch 4 + ST
            dst sp-reg memory-fp-scratch LDDF
        ] [
            21 address 0 count load-memory-bytes
            rep float-rep = [
                21 sp-reg memory-fp-scratch ST dst sp-reg memory-fp-scratch LDF
            ] [
                21 sp-reg memory-fp-scratch STX dst sp-reg memory-fp-scratch LDDF
            ] if
        ] if
    ] if ;
:: unaligned-store-memory ( src address rep count -- )
    rep reg-class-of int-regs = [
        src address 0 count store-memory-bytes
    ] [
        rep float-rep = [
            src sp-reg memory-fp-scratch STF
            21 sp-reg memory-fp-scratch LD 21 address 0 4 store-memory-bytes
        ] [
            src sp-reg memory-fp-scratch STDF
            bootstrap-cell 4 = [
                21 sp-reg memory-fp-scratch LD
                23 sp-reg memory-fp-scratch 4 + LD
                21 address 0 4 store-memory-bytes
                23 address 4 4 store-memory-bytes
            ] [
                21 sp-reg memory-fp-scratch LDX 21 address 0 8 store-memory-bytes
            ] if
        ] if
    ] if ;
:: load-memory ( dst base offset rep type -- )
    rep type memory-width :> count
    count 1 = [ dst base offset rep type aligned-load-memory ] [
        base offset memory-address :> ( address displacement )
        20 address displacement ADDI
        <label> :> slow <label> :> done
        0 20 count 1 - ANDccI slow cc<> branch-cc
        dst 20 0 rep type aligned-load-memory done %jump-label
        slow resolve-label dst 20 rep type count unaligned-load-memory
        done resolve-label
    ] if ;
:: store-memory ( src base offset rep type -- )
    rep type memory-width :> count
    count 1 = [ src base offset rep type aligned-store-memory ] [
        rep reg-class-of int-regs = [
            src base offset store-address :> ( source address displacement )
            21 source int-rep %copy 20 address displacement ADDI
        ] [
            base offset memory-address :> ( address displacement )
            20 address displacement ADDI
        ] if
        rep reg-class-of int-regs = 21 src ? :> value
        <label> :> slow <label> :> done
        0 20 count 1 - ANDccI slow cc<> branch-cc
        value 20 0 rep type aligned-store-memory done %jump-label
        slow resolve-label value 20 rep count unaligned-store-memory
        done resolve-label
    ] if ;
M: sparc %load-memory-imm load-memory ;
M: sparc %store-memory-imm store-memory ;
M:: sparc %load-memory ( dst base index scale offset rep type -- )
    scratch-reg index scale %shl-imm
    scratch-reg base scratch-reg ADD
    dst scratch-reg offset rep type load-memory ;
M:: sparc %store-memory ( src base index scale offset rep type -- )
    scratch-reg index scale %shl-imm
    scratch-reg base scratch-reg ADD
    src scratch-reg offset rep type store-memory ;
M:: sparc %convert-integer ( dst src type -- )
    type heap-size 8 * :> width
    width bootstrap-cell-bits < [
        dst src bootstrap-cell-bits width - %shl-imm
        dst dst bootstrap-cell-bits width - type c-type-signed
        [ %sar-imm ] [ %shr-imm ] if
    ] [ dst src int-rep %copy ] if ;

M:: sparc %box-alien ( dst src temp -- )
    20 src int-rep %copy
    <label> :> end dst \ f type-number %load-immediate
    0 20 0 SUBccI end cc= branch-cc
    dst 5 bootstrap-cells alien temp %allot
    scratch-reg dst tag-mask get ANDNI
    temp \ f type-number %load-immediate
    temp scratch-reg 1 bootstrap-cells %cell-store
    temp scratch-reg 2 bootstrap-cells %cell-store
    20 scratch-reg 3 bootstrap-cells %cell-store
    20 scratch-reg 4 bootstrap-cells %cell-store end resolve-label ;
M:: sparc %box-displaced-alien ( dst displacement base temp class -- )
    20 base int-rep %copy 21 displacement int-rep %copy
    <label> :> end <label> :> alien-path <label> :> false-path
    dst 20 int-rep %copy 0 21 0 SUBccI end cc= branch-cc
    dst 5 bootstrap-cells alien temp %allot
    temp \ f type-number %load-immediate
    temp dst 2 bootstrap-cells alien type-number - %cell-store
    0 20 \ f type-number SUBccI false-path cc= branch-cc
    scratch-reg 20 tag-mask get ANDI
    0 scratch-reg alien type-number SUBccI alien-path cc= branch-cc
    20 dst 1 bootstrap-cells alien type-number - %cell-store
    21 dst 3 bootstrap-cells alien type-number - %cell-store
    temp 20 byte-array-offset ADDI temp temp 21 ADD
    temp dst 4 bootstrap-cells alien type-number - %cell-store end %jump-label
    alien-path resolve-label
    temp 20 1 bootstrap-cells alien type-number - %cell-load
    temp dst 1 bootstrap-cells alien type-number - %cell-store
    temp 20 2 bootstrap-cells alien type-number - %cell-load
    temp dst 2 bootstrap-cells alien type-number - %cell-store
    temp 20 3 bootstrap-cells alien type-number - %cell-load
    temp temp 21 ADD temp dst 3 bootstrap-cells alien type-number - %cell-store
    temp 20 4 bootstrap-cells alien type-number - %cell-load
    temp temp 21 ADD temp dst 4 bootstrap-cells alien type-number - %cell-store
    end %jump-label false-path resolve-label
    20 dst 1 bootstrap-cells alien type-number - %cell-store
    21 dst 3 bootstrap-cells alien type-number - %cell-store
    21 dst 4 bootstrap-cells alien type-number - %cell-store end resolve-label ;

:: float-condition ( cc -- n )
    cc { { cc< 4 } { cc<= 13 } { cc> 6 } { cc>= 11 }
      { cc= 9 } { cc<> 2 } { cc<>= 15 }
      { cc/< 12 } { cc/<= 5 } { cc/> 14 } { cc/>= 3 }
      { cc/= 1 } { cc/<> 10 } { cc/<>= 7 } } at ;
:: float-branch ( label cc -- )
    cc float-condition 0 f FBfcc label rc-native-0 label-fixup NOP ;
M:: sparc %compare-float-ordered-branch ( label src1 src2 cc -- )
    0 src1 src2 FCMPED NOP label cc float-branch ;
M:: sparc %compare-float-unordered-branch ( label src1 src2 cc -- )
    0 src1 src2 FCMPD NOP label cc float-branch ;
:: float-compare-result ( dst cc -- )
    <label> :> yes <label> :> end
    yes cc float-branch
    dst \ f type-number %load-immediate end %jump-label
    yes resolve-label dst \ t %load-reference end resolve-label ;
M:: sparc %compare-float-ordered ( dst src1 src2 cc temp -- )
    0 src1 src2 FCMPED NOP dst cc float-compare-result ;
M:: sparc %compare-float-unordered ( dst src1 src2 cc temp -- )
    0 src1 src2 FCMPD NOP dst cc float-compare-result ;

:: overflow-branch ( label cc -- )
    cc cc-o = [ label 7 branch ] [ label 15 branch ] if ;
M:: sparc %fixnum-add ( label dst src1 src2 cc -- )
    dst src1 src2 ADDcc label cc overflow-branch ;
M:: sparc %fixnum-sub ( label dst src1 src2 cc -- )
    dst src1 src2 SUBcc label cc overflow-branch ;
M:: sparc.32 %fixnum-mul ( label dst src1 src2 cc -- )
    dst src1 src2 SMUL scratch-reg RDY
    scratch2-reg dst 31 SRAI
    0 scratch-reg scratch2-reg SUBcc
    label cc cc-o = [ cc/= ] [ cc= ] if branch-cc ;

M:: sparc %log2 ( dst src -- )
    <label> :> loop <label> :> end
    scratch-reg src int-rep %copy dst -1 %load-immediate
    loop resolve-label 0 scratch-reg 0 SUBccI end cc= branch-cc
    dst dst 1 ADDI scratch-reg scratch-reg 1 %shr-imm
    loop %jump-label end resolve-label ;
M:: sparc %bit-count ( dst src -- )
    <label> :> loop <label> :> end
    scratch-reg src int-rep %copy dst 0 %load-immediate
    loop resolve-label 0 scratch-reg 0 SUBccI end cc= branch-cc
    scratch2-reg scratch-reg 1 SUBI
    scratch-reg scratch-reg scratch2-reg AND dst dst 1 ADDI
    loop %jump-label end resolve-label ;

M:: sparc %min-float ( dst src1 src2 -- )
    <label> :> end fp-scratch-reg src2 double-rep %copy
    0 src1 fp-scratch-reg FCMPD NOP
    dst src1 double-rep %copy end cc<= float-branch
    dst fp-scratch-reg double-rep %copy end resolve-label ;
M:: sparc %max-float ( dst src1 src2 -- )
    <label> :> end fp-scratch-reg src2 double-rep %copy
    0 src1 fp-scratch-reg FCMPD NOP
    dst src1 double-rep %copy end cc>= float-branch
    dst fp-scratch-reg double-rep %copy end resolve-label ;

M:: sparc.64 %fixnum-mul ( label dst src1 src2 cc -- )
    <label> :> done <label> :> check <label> :> overflow
    20 src1 int-rep %copy 21 src2 int-rep %copy
    dst 20 21 MULX
    0 21 0 SUBccI done cc= branch-cc
    0 21 -1 SUBccI check cc/= branch-cc
    scratch-reg -0x8000000000000000 %load-immediate
    0 20 scratch-reg SUBcc overflow cc= branch-cc
    check resolve-label scratch-reg dst 21 SDIVX
    0 scratch-reg 20 SUBcc overflow cc/= branch-cc
    done resolve-label
    cc cc/o = [ label %jump-label ] when
    <label> :> end end %jump-label
    overflow resolve-label cc cc-o = [ label %jump-label ] when
    end resolve-label ;
M:: sparc %bit-test ( dst src index temp -- )
    scratch-reg 1 %load-immediate scratch-reg scratch-reg index %shl
    0 src scratch-reg ANDcc dst cc/= boolean ;
! The map names the faulting LDUB, after the fixed-width address literal.
M: sparc.32 safepoint-gc-map-offset 8 ;
M: sparc.64 safepoint-gc-map-offset 32 ;

M: sparc.32 %safepoint
    scratch-reg 0 SET32 rc-native-1 rel-safepoint
    0 scratch-reg 0 LDUB ;
M: sparc.64 %safepoint
    ! This prefix precedes SAVE; o5 still holds a native callback argument.
    13 sp-reg stack-bias 168 + STX
    scratch-reg 13 0 SET64 rc-native-1 rel-safepoint
    13 sp-reg stack-bias 168 + LDX
    0 scratch-reg 0 LDUB ;
