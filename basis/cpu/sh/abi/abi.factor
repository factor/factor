! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.arrays alien.c-types arrays assocs classes.struct
compiler.cfg.builder.alien.boxing compiler.cfg.builder.alien.params
cpu.architecture cpu.sh.assembler kernel locals math math.bitwise math.order namespaces sequences system vectors ;
IN: cpu.sh.abi

! SH4 allocates logical single lanes, but little-endian single arguments
! reverse each pair. Double arguments use their even physical DR number.
TUPLE: abi-float-register { n integer initial: 0 } ;
C: <abi-float-register> abi-float-register
! Record FP slots carry opaque native bytes, rather than scalar IEEE values.
TUPLE: native-float-register { reg object } ;
C: <native-float-register> native-float-register
SYMBOLS: native-record-parameter? consecutive-complex-lanes? ;
:: abi-register ( reg rep -- reg' )
    reg native-float-register? [ reg reg>> ] [ reg ] if :> reg
    reg abi-float-register? [
        reg n>> rep float-rep? sh-big-endian? get not and [ 1 bitxor ] when
    ] [ reg ] if ;
M: sh4 param-regs
    drop { { int-regs { 4 5 6 7 } }
      { float-regs { T{ abi-float-register f 4 } T{ abi-float-register f 5 }
          T{ abi-float-register f 6 } T{ abi-float-register f 7 }
          T{ abi-float-register f 8 } T{ abi-float-register f 9 }
          T{ abi-float-register f 10 } T{ abi-float-register f 11 } } } } ;
! NetBSD's physical SH4 ports use the __SH3__ soft ABI. The integer-only
! VM rejects foreign floating signatures before parameter classification.
M: sh3 param-regs
    drop { { int-regs { 4 5 6 7 } } { float-regs { } } } ;
M: sh3 return-regs { { int-regs { 0 1 } } { float-regs { } } } ;
M: sh return-regs { { int-regs { 0 1 } } { float-regs { 0 } } } ;
M: sh dummy-stack-params? f ;
M: sh dummy-int-params? f ;
M: sh dummy-fp-params? f ;
M: sh long-long-on-stack? f ;
M: sh long-long-odd-register? f ;
! GNU hard-FPU SH4 keeps a 64-bit integer wholly in registers or wholly
! on the stack. This flag rejects a lone R7; it does not align the pair.
M: sh4 long-long-odd-register? t ;
M: sh4 prepare-long-long-registers drop ;
M: sh long-long-even-register? f ;
M: sh float-right-align-on-stack? f ;
M: sh struct-return-on-stack? f ;
M: sh struct-return-register 2 ;
M: sh return-struct-pointer? f ;
M: sh value-struct? drop t ;

M:: sh4 prepare-abi-parameter-group ( rep -- )
    rep length 4 > [ 4 rep nth 0 > ] [ f ] if
    rep first { float-rep double-rep } member? and
    rep length 6 = [ 5 rep nth or ] when
    native-record-parameter? set
    ! GNU SCmode keeps an even-start complex pair in physical lane order.
    ! An odd-start pair uses the ordinary little-endian lane reversal.
    rep length 6 = [ 5 rep nth ] [ f ] if [
        4 rep nth 0 > [
            float-regs get dup empty? [ drop f ] [ last n>> even? ] if
        ] [ consecutive-complex-lanes? get ] if
    ] [ f ] if
    consecutive-complex-lanes? set
    rep first double-rep? [
        float-regs get :> regs
        rep length 6 = [ 5 rep nth 4 rep nth 0 > and ] [ f ] if [
            regs length 4 < [ regs delete-all ] when
        ] when
        regs empty? [ ] [ regs last n>> odd? [ regs pop* ] when ] if
        regs length 2 < [ regs delete-all ] [
            regs pop :> even-lane regs pop* even-lane regs push
        ] if
    ] when ;
! GCC compute_record_mode/compute_array_mode: a fixed integer mode needs
! scalar-sized members and sufficient aggregate alignment. An alignment-only
! BLK member can still be embedded in a more strongly aligned parent.
GENERIC: mode-info ( type -- rep capable? )
M: object mode-info c-type-rep t ;
! Encoded C strings are array-shaped metadata for one pointer leaf.
M: string-type mode-info c-type-rep t ;
M:: array mode-info ( type -- rep capable? )
    type first lookup-c-type mode-info :> ( element-rep capable? )
    type heap-size { 1 2 4 8 } member? capable? and :> capable?
    type heap-size type first heap-size = element-rep int-rep ? capable? ;
M:: struct-c-type mode-info ( type -- rep capable? )
    type fields>> :> fields
    fields [ type>> lookup-c-type mode-info nip ] all?
    type heap-size { 1 2 4 8 } member? and :> capable?
    fields length 1 = [ fields first type>> heap-size type heap-size = ] [ f ] if
    [ fields first type>> lookup-c-type mode-info drop ] [ int-rep ] if capable? ;
:: register-record? ( type -- ? )
    type lookup-c-type :> c-type
    c-type mode-info nip c-type c-type-align c-type heap-size 4 min >= and ;
: complex-c-type? ( type -- ? ) base-type boxed-class>> complex eq? ;
M: sh return-struct-in-registers? register-record? ;
M: sh4 return-struct-in-registers?
    dup complex-c-type? [ drop t ] [ register-record? ] if ;
:: struct-reps ( type -- reps )
    type complex-c-type? [
        type fields>> [ type>> lookup-c-type c-type-rep f f 3array ] map record-reg-reps
    ] [
        type register-record? [ type mode-info drop ] [ int-rep ] if :> rep
        rep { float-rep double-rep } member? [ rep f f 3array 1array ]
        [ type heap-size 4 align 4 /i { int-rep f f } <array> ] if record-reg-reps
    ] if ;
! GNU hard-FPU SH4 keeps each record argument in one register bank or on
! the stack. Return values keep the ungrouped register representation.
:: mark-record-parameter-group ( reps -- reps' )
    reps [| rep i |
        rep first3 rep first rep-size 4array
        i 0 = reps length 0 ? suffix
    ] map-index ;
M:: sh4 flatten-struct-type ( type -- reps )
    type struct-reps mark-record-parameter-group
    type complex-c-type? [ [ t suffix ] map ] when ;
M: sh4 flatten-struct-type-return struct-reps ;

M: sh4 spill-abi-parameter-registers drop ;

M:: sh4 alloc-abi-parameter ( vreg rep on-stack? odd-register? size -- handled? )
    stack-group-remaining get 0 or 0 >
    native-record-parameter? get not and [
        rep size alloc-parameter-stack-slot :> offset
        vreg rep offset size 4array stack-values get push t
    ] [
        native-record-parameter? get rep { float-rep double-rep } member? and [
            on-stack? float-regs get empty? or
            stack-group-remaining get 0 or 0 > or [
                rep size alloc-parameter-stack-slot :> offset
                vreg rep offset size 4array t suffix stack-values get push
            ] [
                odd-register? rep next-reg-param :> lane
                consecutive-complex-lanes? get rep float-rep? and [
                    lane n>> 1 bitxor <abi-float-register>
                ] [ lane ] if <native-float-register> :> reg
                vreg rep reg 3array reg-values get push
            ] if t
        ] [ f ] if
    ] if ;
M:: sh4 return-regs-for-type ( type -- regs )
    type complex-c-type? [
        type heap-size 8 = [ { 0 1 } ] [ { 0 2 } ] if
        [ <native-float-register> ] map float-regs swap 2array 1array
    ] [
        type struct-c-type? [
            type register-record? type mode-info drop { float-rep double-rep } member? and
        ] [ f ] if [
            { { int-regs { 0 1 } } { float-regs { T{ native-float-register f 0 } } } }
        ] [ return-regs ] if
    ] if ;
! Soft-ABI records travel in consecutive integer words, including records
! whose field metadata contains a floating type. Executing those signatures
! is blocked by the integer-only capability guard.
M: sh3 flatten-struct-type
    heap-size 4 align 4 /i { int-rep f f } <array> record-reg-reps ;
M: sh3 flatten-struct-type-return flatten-struct-type ;
