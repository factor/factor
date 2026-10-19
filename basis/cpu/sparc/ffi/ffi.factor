! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.arrays alien.c-types arrays assocs classes.struct combinators
compiler.cfg compiler.cfg.builder.alien.boxing compiler.cfg.instructions compiler.cfg.hats compiler.cfg.registers
compiler.cfg.builder.alien.params
compiler.codegen.gc-maps compiler.codegen.labels compiler.codegen.relocation compiler.constants
cpu.architecture cpu.sparc cpu.sparc.assembler kernel layouts locals
math math.order namespaces sequences sequences.generalizations sequences.repeating system vectors vm words ;
IN: cpu.sparc.ffi

! V9 parameter registers are positional; a GP parameter consumes its
! corresponding floating slot, and vice versa. Single FP parameters use
! the odd register within that slot. The return FP register remains f0.
SYMBOLS: sparc-extra-param? sparc-aggregate-base sparc-extra-offset ;

M: sparc.64 param-regs
    drop { { int-regs { 8 9 10 11 12 13 } }
           { float-regs { 0 2 4 6 8 10 12 14 16 18 20 22 24 26 28 30 } } } ;
M: sparc return-regs
    { { int-regs { 8 9 10 11 } } { float-regs { 0 2 4 6 } } } ;
M: sparc.64 dummy-stack-params? sparc-extra-param? get not ;
M: sparc.64 dummy-int-params? sparc-extra-param? get not ;
M: sparc.64 dummy-fp-params? t ;
M: sparc long-long-on-stack? f ;
M: sparc long-long-odd-register? f ;
M: sparc.64 float-right-align-on-stack? t ;
M: sparc.64 struct-return-on-stack? f ;
M: sparc.64 value-struct? heap-size 16 <= ;
M: sparc.64 return-struct-in-registers? heap-size 32 <= ;

: param@ ( n -- offset ) bootstrap-cell 8 = [ 128 ] [ 68 ] if + stack-bias + ;
GENERIC#: load-param 1 ( reg src rep -- )
M: integer load-param %copy ;
M: spill-slot load-param swap %reload ;
GENERIC#: store-param 1 ( reg dst rep -- )
M: integer store-param [ swap ] dip %copy ;
M: spill-slot store-param swap %spill ;

HOOK: flush-other-windows cpu ( -- )
M: sparc.32 flush-other-windows FLUSH-WINDOWS-V8 ;
M: sparc.64 flush-other-windows FLUSHW ;
: flush-windows ( -- )
    ! FLUSHW flushes other windows. Materialize the current chain too.
    frame-reg sp-reg 14 bootstrap-cells stack-bias + %cell-store
    31 sp-reg 15 bootstrap-cells stack-bias + %cell-store
    flush-other-windows ;
M:: sparc %save-context ( temp1 temp2 -- )
    temp1 sp-reg stack-bias 4096 - %cell-load
    flush-windows temp1 %context
    temp2 sp-reg stack-bias ADDI
    temp2 temp1 context-callstack-top-offset %cell-store
    ds-reg temp1 context-datastack-offset %cell-store
    rs-reg temp1 context-retainstack-offset %cell-store ;

! Native code may use the application globals. Window locals preserve
! Factor's stack pointers and VM pointer even when libc allocates g2-g4.
: save-globals ( -- )
    20 ds-reg int-rep %copy 21 rs-reg int-rep %copy 22 vm-reg int-rep %copy ;
: restore-globals ( -- )
    ds-reg 20 int-rep %copy rs-reg 21 int-rep %copy vm-reg 22 int-rep %copy ;
:: restore-native-return ( -- )
    31 sp-reg 15 bootstrap-cells stack-bias + %cell-load
    os openbsd? bootstrap-cell 8 = and [
        ! A kernel spill encodes i7 even after RESTORE decoded the live
        ! register. Decode the saved link before reloading it into i7.
        <label> :> plain
        0 31 3 ANDccI plain 1 branch
        scratch-reg 0 %set-cell
        "factor_sparc_window_cookie" f rc-native-1 rel-dlsym
        scratch-reg scratch-reg 0 %cell-load
        31 31 scratch-reg XOR
        plain resolve-label
    ] when ;
:: native-call ( stack-size gc-map -- )
    ! Native trampoline2 owns the adapter return. Its stable C return PC
    ! permits moving GC to patch the adapter's saved i7 before returning.
    stack-size reserved-area + 16 align :> frame-size
    0 sp-reg stack-bias 4096 - %cell-load
    frame-size 4096 < [ sp-reg sp-reg frame-size neg SAVEI ] [
        5 frame-size neg %load-immediate sp-reg sp-reg 5 SAVE
    ] if
    6 <iota> [| index | index 8 + index 24 + int-rep %copy ] each
    bootstrap-cell 4 = [
        5 frame-reg 64 LD 5 sp-reg 64 ST
    ] when
    stack-size bootstrap-cell align bootstrap-cell /i <iota> [| index |
        5 frame-reg index bootstrap-cells param@ %cell-load
        5 sp-reg index bootstrap-cells param@ %cell-store
    ] each
    5 %context
    15 0 %set-cell rc-native-1 rel-trampoline2
    15 15 0 JMPLI NOP gc-map gc-map-here
    ! The native helper already performed RESTORE. Current i7 may have
    ! changed while its window was flushed during moving GC.
    restore-native-return
    5 %context scratch2-reg sp-reg stack-bias ADDI
    scratch2-reg 5 context-callstack-top-offset %cell-store ;
M:: sparc %c-invoke ( name dll gc-map -- )
    scratch-reg 0 %set-cell name dll rc-native-1 rel-dlsym
    0 gc-map native-call ;
M: sparc %alien-global
    [ 0 %set-cell ] 2dip rc-native-1 rel-dlsym ;

M:: sparc %unbox ( dst src func rep -- )
    8 src int-rep load-param 9 vm-reg int-rep %copy
    func f f %c-invoke
    rep reg-class-of return-regs at first dst rep store-param ;
M:: sparc %box ( dst src func rep gc-map -- )
    rep reg-class-of cdecl param-regs at first
    rep float-rep = [ 1 + ] when src rep load-param
    9 vm-reg int-rep %copy func f gc-map %c-invoke
    8 dst int-rep store-param ;
M:: sparc %unbox-long-long ( dst1 dst2 src func -- )
    8 src int-rep load-param 9 vm-reg int-rep %copy
    func f f %c-invoke
    8 dst1 int-rep store-param 9 dst2 int-rep store-param ;
M:: sparc %box-long-long ( dst src1 src2 func gc-map -- )
    8 src1 int-rep load-param 9 src2 int-rep load-param
    10 vm-reg int-rep %copy func f gc-map %c-invoke 8 dst int-rep store-param ;

:: store-stack-param ( vreg rep offset -- )
    rep reg-class-of int-regs = scratch-reg fp-scratch-reg ? :> temp
    temp rep vreg %reload temp sp-reg offset param@ rep f store-memory ;
:: load-stack-param ( vreg rep offset -- )
    rep reg-class-of int-regs = scratch-reg fp-scratch-reg ? :> temp
    scratch2-reg frame-reg 6 bootstrap-cells stack-bias + %cell-load
    temp scratch2-reg offset param@ stack-bias - rep f load-memory
    temp rep vreg %spill ;
:: store-reg-param ( vreg rep reg -- )
    reg rep float-rep = [ 1 + ] when rep vreg %reload
    bootstrap-cell 8 = rep int-rep = and [
        reg sp-reg reg 8 - bootstrap-cells param@ %cell-store
    ] when ;
:: load-reg-param ( vreg rep reg -- ) reg rep vreg %spill ;
:: mirror-fp-param ( vreg rep reg -- )
    rep reg-class-of float-regs = [
        fp-scratch-reg rep vreg %reload
        reg rep float-rep = [ 1 + ] when :> physical
        fp-scratch-reg sp-reg physical 4 * param@ rep f store-memory
        physical 12 < [
            physical 2 /i 8 + sp-reg physical 2 /i bootstrap-cells param@ %cell-load
        ] when
    ] when ;

:: emit-alien ( varargs? reg-inputs stack-inputs reg-outputs dead-outputs cleanup stack-size quot -- )
    stack-inputs [ first3 store-stack-param ] each
    reg-inputs [ first3 store-reg-param ] each
    varargs? bootstrap-cell 8 = and [ reg-inputs [ first3 mirror-fp-param ] each ] when
    quot call
    reg-outputs [ first3 load-reg-param ] each ; inline
M:: sparc %alien-invoke ( varargs? reg-inputs stack-inputs reg-outputs dead-outputs cleanup stack-size name dll gc-map -- )
    varargs? reg-inputs stack-inputs reg-outputs dead-outputs cleanup stack-size [
        scratch-reg 0 %set-cell name dll rc-native-1 rel-dlsym
        stack-size gc-map native-call
    ] emit-alien ;
M:: sparc %alien-indirect ( src varargs? reg-inputs stack-inputs reg-outputs dead-outputs cleanup stack-size gc-map -- )
    varargs? reg-inputs stack-inputs reg-outputs dead-outputs cleanup stack-size [
        scratch-reg src int-rep load-param stack-size gc-map native-call
    ] emit-alien ;
M: sparc %alien-assembly '[ _ call( -- ) ] emit-alien ;
M: sparc %callback-stack
    frame-reg 6 bootstrap-cells stack-bias + %cell-load ;
:: load-callback-reg ( vreg rep reg -- )
    rep reg-class-of int-regs = [ reg 16 + ] [ reg rep float-rep = [ 1 + ] when ] if
    rep vreg %spill ;
:: store-callback-reg ( vreg rep reg -- )
    rep reg-class-of int-regs = [ reg 16 + ] [ reg ] if rep vreg %reload ;
M: sparc %callback-inputs
    [ [ first3 load-callback-reg ] each ]
    [ [ first3 load-stack-param ] each ] bi*
    8 vm-reg int-rep %copy 9 0 %load-immediate
    "begin_callback" f f %c-invoke ;
M: sparc %callback-outputs
    8 vm-reg int-rep %copy "end_callback" f f %c-invoke
    [ first3 store-callback-reg ] each ;

M: sparc.32 param-regs
    drop { { int-regs { 8 9 10 11 12 13 } } { float-regs { } } } ;
M: sparc.32 dummy-stack-params? t ;
M: sparc.32 dummy-int-params? f ;
M: sparc.32 dummy-fp-params? f ;
M: sparc.32 float-right-align-on-stack? f ;
M: sparc.32 struct-return-on-stack? f ;
M: sparc.32 struct-return-stack-offset -4 ;
! GNU aggregate callees retain the hidden result pointer in o0.
M: sparc return-struct-pointer? t ;
! Indirect V8 structure returns skip the caller's UNIMP size marker.
M:: sparc.32 stack-cleanup ( stack-size return abi -- n )
    return large-struct? 4 0 ? ;
M: sparc.32 value-struct? drop f ;
: complex-struct? ( type -- ? )
    base-type dup struct-c-type?
    [ boxed-class>> complex eq? ] [ drop f ] if ;
! V8 returns C complex values in f0/f1 or the f0/f2 double pairs.
! Ordinary aggregates still use the caller's result area.
M: sparc.32 return-struct-in-registers? complex-struct? ;
M: sparc.32 flatten-struct-type-return
    dup complex-struct? [
        heap-size 8 = float-rep double-rep ? f f 3array
        2 swap <array> record-reg-reps
    ] [ flatten-struct-type ] if ;
M: sparc.32 return-regs-for-type
    dup complex-struct? [ heap-size 8 = ] [ drop f ] if [
        { { int-regs { 8 9 10 11 } } { float-regs { 0 1 } } }
    ] [ return-regs ] if ;

! V8 FP arguments use integer payload words in big-endian memory order.
M:: sparc.32 flatten-scalar-parameter ( type -- reps )
    type rep>> reg-class-of float-regs = [
        type heap-size bootstrap-cell /i { int-rep f f } <array> record-reg-reps
    ] [ type flatten-c-type ] if ;
M:: sparc.32 unbox-scalar-parameter ( src type -- vregs reps )
    type rep>> reg-class-of float-regs = [
        src type unbox :> ( fp-vregs fp-reps )
        fp-reps unrecord-reg-reps drop
        8 8 f ^^local-allot :> buffer
        fp-vregs first buffer 0 type rep>> f ##store-memory-imm,
        type heap-size bootstrap-cell /i <iota> [| index |
            buffer index bootstrap-cells int-rep f ^^load-memory-imm
        ] map type flatten-scalar-parameter
    ] [ src type unbox ] if ;
M:: sparc.32 box-scalar-parameter ( vregs reps type -- dst )
    type rep>> reg-class-of float-regs = [
        8 8 f ^^local-allot :> buffer
        vregs [| reg index | reg buffer index bootstrap-cells int-rep f ##store-memory-imm, ] each-index
        buffer 0 type rep>> f ^^load-memory-imm
    ] [ vregs reps type box ] if ;


M:: sparc.32 %box ( dst src func rep gc-map -- )
    rep reg-class-of float-regs = [
        fp-scratch-reg src rep load-param
        fp-scratch-reg sp-reg 80 rep f store-memory
        8 sp-reg 80 LD
        rep double-rep = [ 9 sp-reg 84 LD 10 ] [ 9 ] if
        vm-reg int-rep %copy
    ] [ 8 src rep load-param 9 vm-reg int-rep %copy ] if
    func f gc-map %c-invoke 8 dst int-rep store-param ;

! Integer chunks preserve the exact C object layout. FP fields shadow the
! same chunks without consuming new positions in the parameter array.
TUPLE: sparc-abi-member offset c-type floating? ;
C: <sparc-abi-member> sparc-abi-member

GENERIC: sparc-fp-members ( type -- members )
M: object sparc-fp-members
    c-type-rep dup { float-rep double-rep } member?
    [ 0 swap 2array 1array ] [ drop { } ] if ;
:: offset-fp-members ( members offset -- members' )
    members [ first2 [ offset + ] dip 2array ] map ;
! Encoded strings are pointer-backed arrays, not by-value C arrays.
M: string-type sparc-fp-members drop { } ;
! GNU/Linux V9 array fields stay in integer chunks. Preserve the existing
! classification elsewhere until each target's native ABI is qualified.
M:: array sparc-fp-members ( type -- members )
    os linux? [ { } ] [
        type unclip [ array-length ] [ lookup-c-type ] bi* :> ( count element )
        element sparc-fp-members :> members
        count <iota> [ members swap element heap-size * offset-fp-members ] map concat
    ] if ;
M:: struct-c-type sparc-fp-members ( type -- members )
    type fields>> :> fields
    type boxed-class>> "union-struct" word-prop [ { } ] [
        fields [| field |
            field type>> lookup-c-type sparc-fp-members
            field offset>> offset-fp-members
        ] map concat
        [ first2 rep-size mod 0 = ] filter
    ] if ;

:: member-rep ( rep size offset type floating? -- tuple )
    offset type floating? <sparc-abi-member> :> member
    ! FP shadows have no independent allocation group, including on the stack.
    rep f f size floating? [ 0 ] [ 1 ] if f f 8 member 9 narray ;
:: sparc-struct-reps ( type -- reps )
    type lookup-c-type :> c-type
    c-type heap-size :> size
    c-type sparc-fp-members :> floats
    size 8 align 8 /i <iota> [| index |
        index 8 * :> offset
        size offset - 8 min :> remaining
        remaining 8 < [ remaining <partial-struct-cell> ] [ f ] if :> part
        int-rep 8 offset part f member-rep :> integer
        floats [ first 8 /i index = ] filter [| field |
            field first2 :> ( field-offset rep )
            rep rep rep-size field-offset f t member-rep
        ] map
        integer prefix
    ] map concat ;
M: sparc.64 flatten-struct-type
    dup heap-size 16 <= [ sparc-struct-reps record-reg-reps ] [ call-next-method ] if ;
M: sparc.64 flatten-struct-type-return
    dup heap-size 32 <= [ sparc-struct-reps record-reg-reps ] [ call-next-method ] if ;
M:: sparc.64 struct-components ( reps type -- offsets types )
    reps [ reg-class-of float-regs = ] any? [
        type sparc-struct-reps
        [ [ 8 swap nth offset>> ] map ]
        [ [ 8 swap nth c-type>> ] map ] bi
    ] [ reps type integer-struct-components ] if ;

: abi-member ( tuple -- member/f )
    dup length 9 = [ 8 swap nth ] [ drop f ] if ;
:: reset-param-banks ( slot -- )
    6 slot - 0 max <iota> [ slot 8 + + ] map <reversed> >vector int-regs set
    16 slot - 0 max <iota> [ slot + 2 * ] map <reversed> >vector float-regs set ;
M:: sparc.64 prepare-abi-parameter-group ( tuple -- )
    tuple abi-member :> member
    member [ member floating?>> ] [ f ] if :> extra?
    extra? sparc-extra-param? set
    extra? [
        sparc-aggregate-base get member offset>> + :> offset
        offset sparc-extra-offset set
        offset 4 /i :> physical
        physical 32 < [
            physical tuple first float-rep = [ 1 - ] when 1array >vector
        ] [ V{ } clone ] if float-regs set
    ] [
        stack-params get 8 /i reset-param-banks
        member [ stack-params get member offset>> - sparc-aggregate-base set ] when
    ] if ;
M: sparc.64 alloc-abi-stack-param
    sparc-extra-param? get [ 2drop sparc-extra-offset get ] [
        compact-stack-params? get [ alloc-stack-param ] [
            ! V9 parameter slots are eight bytes even when inspecting
            ! this ABI from a 32-bit VM.
            drop stack-params get swap dup rep-size 8 align
            dup stack-params +@ swap float-rep =
            [ 4 - + ] [ drop ] if
        ] if
    ] if ;
M: sparc.64 abi-param-slot-count rep-size 8 /i 1 max ;
M: sparc.64 abi-return-register
    dup abi-member [
        nip [ offset>> ] [ floating?>> ] bi
        [ 4 /i ] [ 8 /i 8 + ] if
    ] [ first next-return-reg ] if* ;
M:: sparc.64 store-callback-return ( vregs reps type -- triples )
    type struct-c-type? type return-struct-in-registers? and [
        vregs type sparc-struct-reps [| vreg tuple |
            vreg tuple first tuple abi-return-register 3array
        ] 2map
    ] [ vregs reps store-return ] if ;
