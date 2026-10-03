! Copyright (C) 2026 Factor authors.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.arrays alien.c-types arrays assocs classes.struct
combinators compiler.cfg.builder.alien.boxing compiler.cfg.builder.alien.params compiler.cfg.hats
compiler.cfg.instructions
cpu.architecture kernel layouts locals math math.order namespaces
math.bitwise sequences system words ;
QUALIFIED-WITH: alien.c-types c
IN: cpu.riscv.64.abi

! Each flattened member retains its byte offset, width, representation
! and C type. Padding does not consume an argument register.
GENERIC: abi-members ( c-type -- members/f )

M:: object abi-members ( c-type -- members/f )
    c-type heap-size :> size
    c-type c-type-rep :> rep
    size 8 <= rep { int-rep float-rep double-rep } member? and
    [ 0 size rep c-type 4array 1array ] [ f ] if ;

:: offset-members ( members offset -- members' )
    members [| member |
        member clone :> copy
        member first offset + 0 copy set-nth copy
    ] map ;

M:: array abi-members ( c-type -- members/f )
    c-type unclip :> ( dimensions element )
    element lookup-c-type abi-members :> members
    members [
        dimensions array-length <iota>
        [ element heap-size * members swap offset-members ] map concat
    ] [ f ] if ;

M: string-type abi-members drop void* base-type abi-members ;

:: bitfield-member ( field -- members/f )
    field bits>> :> bits
    bits 0 = [ { } ] [
        bits 64 <= [
            field offset>> 8 /i bits 8 align 8 /i int-rep field 4array 1array
        ] [ f ] if
    ] if ;

M:: struct-c-type abi-members ( c-type -- members/f )
    c-type boxed-class>> "union-struct" word-prop [ f ] [
        c-type fields>> [| field |
            field struct-bit-slot-spec? [ field bitfield-member ] [
                field type>> lookup-c-type abi-members
                [ field offset>> offset-members ] [ f ] if*
            ] if
        ] map dup [ not ] any? [ drop f ] [ concat ] if
    ] if ;

: fp-member? ( member -- ? ) third { float-rep double-rep } member? ;

: fp-struct-members ( c-type -- members/f )
    base-type abi-members dup [
        dup length 1 2 between? over [ fp-member? ] any? and
        [ drop f ] unless
    ] when ;

: member-reps ( members -- reps ) [ third f f 3array ] map ;

:: member-registers-available? ( members -- ? )
    members member-reps reg-reps :> ( ints floats )
    int-reg-reps get 0 or 8 min ints + 8 <=
    float-reg-reps get 0 or 8 min floats + 8 <= and ;

: parameter-fp-members ( c-type -- members/f )
    varargs-parameter? get [ drop f ] [
        fp-struct-members dup [
            dup member-registers-available? [ drop f ] unless
        ] when
    ] if ;

:: mark-integer-struct-reps ( reps alignment -- reps' )
    reps [| rep index |
        rep first3 8 4array 0 suffix alignment suffix
        index 0 = reps length 0 ? suffix
    ] map-index ;

M: riscv.64 value-struct?
    [ heap-size 16 <= ] [ parameter-fp-members >boolean ] bi or ;
M: riscv.64 return-struct-in-registers?
    [ heap-size 16 <= ] [ fp-struct-members >boolean ] bi or ;

M:: riscv.64 flatten-struct-type ( c-type -- reps )
    c-type parameter-fp-members [ member-reps record-reg-reps ] [
        c-type heap-size cell align cell /i { int-rep f f } <array> record-reg-reps
        c-type c-type-align mark-integer-struct-reps
    ] if* ;
M: riscv.64 flatten-struct-type-return
    dup fp-struct-members
    [ nip member-reps record-reg-reps ]
    [ heap-size cell align cell /i { int-rep f f } <array> record-reg-reps ] if* ;

M: riscv.64 struct-components
    over [ { float-rep double-rep } member? ] any? [
        nip fp-struct-members [ [ first ] map ] [ [ fourth ] map ] bi
    ] [ integer-struct-components ] if ;

: scalar-integer-convention? ( c-type -- ? )
    c-type-rep { float-rep double-rep } member?
    float-reg-reps get 0 or 8 >= varargs-parameter? get or and ;

:: integer-abi-payload ( vregs c-type -- vregs' )
    c-type c-type-rep int-rep eq? c-type heap-size 4 <= and [
        vregs first c-type ^^convert-integer
        ! RV64 sign-extends every 32-bit integer, including unsigned int.
        c-type heap-size 4 = [ int base-type ^^convert-integer ] when 1array
    ] [ vregs ] if ;

M:: riscv.64 unbox-scalar-parameter ( src c-type -- vregs reps )
    c-type scalar-integer-convention? :> integer?
    src c-type unbox :> ( vregs reps )
    integer? [
        reps unrecord-reg-reps drop
        vregs first c-type c-type-rep ^^scalar>integer 1array
        { { int-rep f f 8 } } record-reg-reps
    ] [ vregs c-type integer-abi-payload reps ] if ;

M:: riscv.64 unbox-scalar-return ( src c-type -- vregs reps )
    src c-type unbox :> ( vregs reps )
    vregs c-type integer-abi-payload reps keys ;

M: riscv.64 flatten-scalar-parameter
    dup scalar-integer-convention? [
        drop { { int-rep f f 8 } } record-reg-reps
    ] [ flatten-c-type ] if ;

M:: riscv.64 box-scalar-parameter ( vregs reps c-type -- dst )
    reps first int-rep eq?
    c-type c-type-rep { float-rep double-rep } member? and [
        vregs first c-type c-type-rep ^^integer>scalar 1array
        c-type c-type-rep 1array c-type box
    ] [ vregs reps c-type box ] if ;

M:: riscv.64 box-struct-parameter ( vregs reps c-type -- dst )
    c-type heap-size 16 <= reps [ { float-rep double-rep } member? ] any? or
    [ vregs reps c-type box ] [
        vregs first c-type explode-struct keys c-type box
    ] if ;

M:: riscv.64 unbox-struct-parameter ( src c-type -- vregs reps )
    c-type value-struct? [ src c-type unbox ] [
        c-type heap-size c-type c-type-align cell max f ^^local-allot :> buffer
        src ^^unbox-any-c-ptr :> pointer
        pointer buffer c-type copy-struct-data
        buffer 1array { { int-rep f f } } record-reg-reps
    ] if ;

M:: riscv.64 prepare-abi-parameter-group ( rep-tuple -- )
    rep-tuple length 7 = [
        6 rep-tuple nth :> count
        count int-regs get length > [
            5 rep-tuple nth 8 max 16 min :> alignment
            stack-params get alignment align stack-params set
        ] when
    ] when ;
