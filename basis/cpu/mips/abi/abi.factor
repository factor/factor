! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.arrays alien.c-types arrays assocs classes.struct
combinators compiler.cfg.builder.alien compiler.cfg.builder.alien.boxing compiler.cfg.builder.alien.params
compiler.cfg.hats compiler.cfg.instructions cpu.architecture cpu.mips
cpu.mips.assembler.registers kernel layouts literals locals math math.bitwise
math.order namespaces sequences system vectors words ;
QUALIFIED-WITH: alien.c-types c
IN: cpu.mips.abi

M: mips return-regs
    mips-soft-float-abi?
    [ { { int-regs ${ V0 V1 } } { float-regs ${ V0 A0 } } } ]
    [ { { int-regs ${ V0 V1 } } { float-regs ${ F0 F2 } } } ] if ;
M: mips32 param-regs
    drop { { int-regs ${ A0 A1 A2 A3 } } { float-regs ${ F12 F14 } } } ;
M: mips64 param-regs
    drop mips-soft-float-abi? [
        { { int-regs ${ A0 A1 A2 A3 R8 R9 R10 R11 } } { float-regs { } } }
    ] [
        { { int-regs ${ A0 A1 A2 A3 R8 R9 R10 R11 } }
          { float-regs ${ F12 F13 F14 F15 F16 F17 F18 F19 } } }
    ] if ;
M: mips32 dummy-stack-params? t ;
M: mips64 dummy-stack-params? f ;
M: mips dummy-int-params? t ;
M: mips32 dummy-fp-params? f ;
M: mips64 dummy-fp-params? mips-soft-float-abi? not ;
M: mips long-long-on-stack? f ;
! The existing odd-register convention is not MIPS's even-slot alignment.
! Alignment is applied once at the argument group boundary instead.
M: mips long-long-odd-register? f ;
M: mips32 float-right-align-on-stack? f ;
! GNU N64 stores stack floats at the slot base in both byte orders.
! Big-endian integer scalars remain right justified by their full-cell store.
M: mips.64 float-right-align-on-stack? f ;
M: mipsel.64 float-right-align-on-stack? f ;
M: mips struct-return-on-stack? f ;
M: mips value-struct? drop t ;
: complex-c-type? ( type -- ? ) base-type boxed-class>> complex eq? ;
M: mips32 return-struct-in-registers? complex-c-type? ;
M: mips64 return-struct-in-registers? heap-size 16 <= ;

! Keep alignment on the first chunk only. Index4 is deliberately zero:
! MIPS permits aggregates to split between the register and stack areas.
:: mark-argument ( reps alignment -- reps' )
    reps [| rep i |
        rep first3 rep param-natural-size 4array 0 suffix
        i zero? alignment 1 ? suffix
    ] map-index ;

: o32-fp-argument? ( c-type -- ? )
    c-type-rep { float-rep double-rep } member?
    int-reg-reps get 0 or zero? and
    float-reg-reps get 0 or 2 < and
    varargs-parameter? get not and
    varargs-named-count get not and ;
: integer-fp-argument? ( c-type -- ? )
    dup c-type-rep { float-rep double-rep } member?
    [ mips-cpu mips32? [ o32-fp-argument? not ] [ drop varargs-parameter? get varargs-named-count get t eq? or mips-soft-float-abi? or ] if ]
    [ drop f ] if ;

:: integer-fp-reps ( c-type -- reps )
    c-type heap-size mips-cell align mips-cell /i
    { int-rep f f } <array>
    mips-soft-float-abi? c-type c-type-rep float-rep eq? and
    [ [ 4 suffix ] map ] when record-reg-reps ;
! A seventh field marks a four-byte FP payload carried in an integer slot.
! It must be stored at the slot base, unlike a right-justified integer.
:: mark-soft-float ( reps c-type -- reps' )
    mips-soft-float-abi? c-type c-type-rep float-rep eq? and
    [ reps [ float-rep suffix ] map ] [ reps ] if ;
M:: mips unbox-scalar-parameter ( src c-type -- vregs reps )
    c-type integer-fp-argument? :> integer?
    src c-type unbox :> ( vregs reps )
    integer? [
        reps unrecord-reg-reps drop
        mips-cpu mips32? c-type heap-size 8 = and [
            8 8 f ^^local-allot :> buffer
            vregs first buffer 0 double-rep f ##store-memory-imm,
            buffer 0 int-rep f ^^load-memory-imm
            buffer 4 int-rep f ^^load-memory-imm 2array
        ] [ vregs first c-type c-type-rep ^^scalar>integer 1array ] if
        c-type integer-fp-reps
    ] [
        vregs c-type c-type-rep int-rep eq? c-type heap-size 4 = and
        mips-cpu mips64? and [
            ! N64 sign-extends every32-bit argument, including unsignedint.
            [ c:int base-type ^^convert-integer ] map
        ] when reps
    ] if
    c-type c-type-align mark-argument c-type mark-soft-float ;
M:: mips flatten-scalar-parameter ( c-type -- reps )
    c-type integer-fp-argument? [ c-type integer-fp-reps ]
    [ c-type flatten-c-type ] if
    c-type c-type-align mark-argument c-type mark-soft-float ;
M:: mips box-scalar-parameter ( vregs reps c-type -- dst )
    reps first int-rep eq?
    c-type c-type-rep { float-rep double-rep } member? and [
        mips-cpu mips32? c-type heap-size 8 = and [
            8 8 f ^^local-allot :> buffer
            vregs first buffer 0 int-rep f ##store-memory-imm,
            vregs second buffer 4 int-rep f ##store-memory-imm,
            buffer 0 double-rep f ^^load-memory-imm
        ] [ vregs first c-type c-type-rep ^^integer>scalar ] if 1array
        c-type c-type-rep 1array c-type box
    ] [ vregs reps c-type box ] if ;

! N64 FP arguments occupy their positional slot in both register banks.
! O32 doubles and longlongs start at an even four-byte argument slot.
! The generic dummy stack allocator already reserves eight bytes for a
! register double; only align that home area here.
SYMBOL: soft-float-payload?
M:: mips prepare-abi-parameter-group ( rep -- )
    rep length 7 = [ rep last float-rep eq? ] [ f ] if soft-float-payload? set
    rep length 5 > [
        rep length 8 = [ 5 rep nth [ 7 rep nth ] [ 1 ] if ] [ 5 rep nth ] if :> alignment
        mips-cpu mips32? alignment 8 >= and [
            int-regs get dup empty? [ drop ] [
                last n>> odd? [ int-regs get pop* ] when
            ] if
            stack-params get 8 align stack-params set
        ] when
    ] when ;

M:: mips alloc-abi-parameter ( vreg rep on-stack? odd-register? size -- handled? )
    mips-soft-float-abi? soft-float-payload? get and
    on-stack? int-regs get empty? or and [
        rep size alloc-parameter-stack-slot :> offset
        vreg rep offset size 4array float-rep suffix stack-values get push t
    ] [ f ] if ;

M:: mips flatten-scalar-return ( c-type -- reps )
    mips-soft-float-abi? [ c-type integer-fp-argument? ] [ f ] if
    [ c-type integer-fp-reps ] [ c-type flatten-c-type ] if ;
M:: mips unbox-scalar-return ( src c-type -- vregs reps )
    mips-soft-float-abi? [ c-type integer-fp-argument? ] [ f ] if
    [ src c-type unbox-scalar-parameter keys ] [ src c-type unbox keys ] if ;
M:: mips box-scalar-return ( vregs reps c-type -- dst )
    mips-soft-float-abi? [ c-type integer-fp-argument? ] [ f ] if
    [ vregs reps c-type box-scalar-parameter ] [ vregs reps c-type box ] if ;

! N64 passes a full aligned double member in the matching FP slot.
! Float members and every other eight-byte aggregate chunk use GPRs.
GENERIC: abi-members ( type -- members/f )
M:: object abi-members ( type -- members/f )
    type c-type-rep :> rep
    rep { float-rep double-rep } member?
    [ 0 type heap-size rep type 4array 1array ] [ f ] if ;
:: offset-members ( members offset -- members' )
    members [| member | member clone :> copy member first offset + 0 copy set-nth copy ] map ;
M:: array abi-members ( type -- members/f )
    type unclip :> ( dimensions element )
    element lookup-c-type abi-members :> members
    members [ dimensions array-length <iota>
        [ element heap-size * members swap offset-members ] map concat ] [ f ] if ;
! A C string descriptor is a pair array whose first element resolves
! back to the descriptor. It denotes a pointer, not an embedded array.
M: string-type abi-members drop f ;
M:: struct-c-type abi-members ( type -- members/f )
    type boxed-class>> "union-struct" word-prop [ f ] [
        type fields>> [| field |
            field struct-bit-slot-spec? [ f ] [
                field type>> lookup-c-type abi-members
                [ field offset>> offset-members ] [ f ] if*
            ] if
        ] map dup [ not ] any? [ drop f ] [ concat ] if
    ] if ;
: return-fp-members ( type -- members/f )
    base-type abi-members dup [ dup length 1 2 between? [ drop f ] unless ] when ;

! Integer fields do not prevent unrelated aligned double members from
! occupying FP slots, so inspect each field independently for parameters.
GENERIC: double-offsets ( type -- offsets )
M: object double-offsets c-type-rep double-rep eq? [ { 0 } ] [ { } ] if ;
M:: array double-offsets ( type -- offsets )
    type unclip :> ( dimensions element )
    element lookup-c-type double-offsets :> offsets
    dimensions array-length <iota>
    [ element heap-size * [ offsets swap [ + ] curry map ] keep drop ] map concat ;
M: string-type double-offsets drop { } ;
M:: struct-c-type double-offsets ( type -- offsets )
    type boxed-class>> "union-struct" word-prop [ { } ] [
        type fields>> [| field |
            field struct-bit-slot-spec? [ { } ] [
                field type>> lookup-c-type double-offsets
                [ field offset>> + ] map
            ] if
        ] map concat
    ] if ;
:: struct-reps ( type -- reps )
    type base-type double-offsets :> doubles
    type heap-size mips-cell align mips-cell /i <iota> [| i |
        mips-cpu mips64? mips-soft-float-abi? not and varargs-parameter? get not and varargs-named-count get t eq? not and
        i 8 * doubles member? and double-rep int-rep ? f f 3array
    ] map record-reg-reps
    type c-type-align mark-argument ;
M: mips flatten-struct-type struct-reps ;
M:: mips64 flatten-struct-type ( type -- reps )
    type complex-c-type? type heap-size 8 = and mips-soft-float-abi? not and
    varargs-parameter? get not and varargs-named-count get t eq? not and
    int-reg-reps get 0 or float-reg-reps get 0 or + 6 <= and [
        ! GNU N64 gives a named complex float two positional FP slots.
        ! With fewer than two slots left it packs the object into one
        ! GPR or stack slot, preserving its contiguous in-memory layout.
        { { float-rep f f } { float-rep f f } } record-reg-reps
        type c-type-align mark-argument
    ] [ type struct-reps ] if ;
M:: mips32 flatten-struct-type-return ( type -- reps )
    type complex-c-type? [
        type return-fp-members [ third f f 3array ] map record-reg-reps
    ] [ type struct-reps ] if ;
M:: mips64 flatten-struct-type-return ( type -- reps )
    type return-fp-members [ [ third f f 3array ] map record-reg-reps ] [
        type heap-size 8 align 8 /i { int-rep f f } <array> record-reg-reps
    ] if* ;
M:: mips struct-components ( reps type -- offsets types )
    type return-fp-members :> members
    members reps [ { float-rep double-rep } member? ] all? and [
        members [ first ] map members [ fourth ] map
    ] [
        reps type integer-struct-components :> ( offsets types )
        offsets types reps [| offset chunk rep |
            rep double-rep eq? [ double ] [ chunk ] if
        ] 3map offsets swap
    ] if ;
