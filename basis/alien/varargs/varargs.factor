! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.accessors alien.arrays alien.c-types
alien.c-types.varargs alien.data alien.private arrays byte-arrays
classes.struct combinators combinators.short-circuit compiler.units continuations
cpu.architecture cpu.arm.64.abi cpu.s390x.abi grouping kernel layouts libc locals math math.bitwise math.order
namespaces sequences system threads words ;
IN: alien.varargs

ERROR: expired-va-list ;
ERROR: va-list-outside-callback-scope ;
ERROR: unsupported-va-list-platform ;

TUPLE: va-lifetime callback thread active? ;
C: <va-lifetime> va-lifetime

TUPLE: va-cursor stack gr-top vr-top gr-offs vr-offs platform lifetime ;

<PRIVATE
SYMBOL: va-scope

: active-va-lifetime ( -- lifetime )
    va-scope get [ ] [ va-list-outside-callback-scope ] if* ;

: expire-va-lifetime ( -- )
    va-scope get f >>active? drop ;
PRIVATE>

! Place this inside do-callback, after the callback's namespace stack is
! initialized, and around parameter boxing as well as the user's quotation.
: with-va-scope ( quot -- )
    current-callback self t <va-lifetime> va-scope
    [ [ expire-va-lifetime ] finally ] with-variable ; inline

:: <platform-va-cursor> ( stack gr-top vr-top gr-offs vr-offs platform -- cursor )
    va-cursor new
        stack >>stack gr-top >>gr-top vr-top >>vr-top
        gr-offs >>gr-offs vr-offs >>vr-offs platform >>platform
        active-va-lifetime >>lifetime ;

: va-platform ( -- platform ) cpu riscv? cpu loongarch.64? or cpu mips? or cpu s390x? or cpu hppa? or [ cpu ] [ os ] if ;

: <va-cursor> ( stack gr-top vr-top gr-offs vr-offs -- cursor )
    cpu arm.64? cpu riscv? cpu loongarch.64? or or cpu mips? or cpu s390x? or cpu hppa? or
    [ va-platform <platform-va-cursor> ] [ unsupported-va-list-platform ] if ;

: check-va-list ( cursor -- )
    lifetime>> {
        [ active?>> ] [ callback>> current-callback = ] [ thread>> self eq? ]
    } 1&&
    [ expired-va-list ] unless ;

: va-copy ( cursor -- copy ) dup check-va-list clone ;

<PRIVATE

! Metadata is compiled once for each literal va-arg type. The platform
! distinction is made by the reader so synthetic ABI tests can run anywhere.
TUPLE: va-layout size alignment members aggregate? homogeneous? resolved ;

:: <va-layout> ( type -- layout )
    type lookup-c-type :> resolved
    resolved homogeneous-aggregate-members :> members
    va-layout new
        type heap-size >>size type c-type-align >>alignment
        members [ ] [ { } ] if* >>members resolved struct-c-type? >>aggregate?
        members >boolean >>homogeneous? resolved >>resolved ;

: align-va-pointer ( ptr alignment -- ptr' )
    [ alien-address ] dip align <alien> ;

! Synthetic platform cursors retain their target slot width even when
! tests run on a host with a different cell size.
: va-abi-cell ( cursor -- n ) platform>> dup riscv.32? over mips32? or swap hppa? or 4 8 ? ;

! O32 and PA32 align eight-byte scalar arguments to an eight-byte home,
! even when the host C type (for example x86-32 double) is four-aligned.
:: va-target-alignment ( cursor layout -- alignment )
    layout alignment>>
    cursor platform>> dup mips32? swap hppa? or
    layout aggregate?>> not and layout size>> 8 = and
    [ 8 max ] when ;

:: va-stack-address ( cursor size alignment -- ptr )
    cursor stack>> alignment cursor va-abi-cell max align-va-pointer :> ptr
    cursor size cursor va-abi-cell align ptr <displaced-alien> >>stack drop
    ptr ;

:: va-gpr-address ( cursor size alignment -- ptr/f )
    cursor gr-offs>> :> old
    old 0 < [
        old alignment 8 max align :> offset
        offset size 8 align + :> next
        cursor next >>gr-offs drop
        next 0 <= [ offset cursor gr-top>> <displaced-alien> ] [ f ] if
    ] [ f ] if ;

:: va-vr-address ( cursor count -- ptr/f )
    cursor vr-offs>> :> offset
    offset 0 < [
        offset count 16 * + :> next
        cursor next >>vr-offs drop
        next 0 <= [ offset cursor vr-top>> <displaced-alien> ] [ f ] if
    ] [ f ] if ;

:: reassemble-va-hfa ( ptr layout -- bytes )
    layout size>> <byte-array> :> bytes
    layout members>> [| member index |
        member first bytes <displaced-alien>
        index 16 * ptr <displaced-alien> member second memcpy
    ] each-index
    bytes ;

:: va-indirect? ( cursor layout -- ? )
    cursor platform>> mips? [ f ] [
        layout aggregate?>> layout size>> cursor va-abi-cell 2 * > and
        cursor platform>> dup windows? over riscv? or swap loongarch.64? or layout homogeneous?>> not or and
    ] if ;

:: va-linux-address ( cursor layout indirect? -- ptr )
    indirect? [ cursor va-abi-cell dup ] [ layout size>> layout alignment>> ] if :> ( size alignment )
    layout homogeneous?>> indirect? not and [
        cursor layout members>> length va-vr-address [
            layout aggregate?>> [ layout reassemble-va-hfa ] when
        ] [ cursor size alignment va-stack-address ] if*
    ] [
        cursor size alignment va-gpr-address
        [ ] [ cursor size alignment va-stack-address ] if*
    ] if ;

! System z has five eight-byte GP slots and four eight-byte FP slots.
! Small GP values are right justified; FP values start at the slot base.
:: va-s390x-address ( cursor layout -- ptr )
    layout resolved>> single-fp-rep >boolean :> fp?
    layout aggregate?>>
    layout resolved>> M\ s390x value-struct? execute not and :> indirect?
    indirect? 8 layout size>> ? :> size
    fp? [
        cursor vr-offs>> :> offset
        offset 0 < [
            cursor offset 8 + >>vr-offs drop
            offset cursor vr-top>> <displaced-alien>
        ] [
            cursor 8 8 va-stack-address
            8 size - swap <displaced-alien>
        ] if
    ] [
        cursor 8 8 va-gpr-address
        [ ] [ cursor 8 8 va-stack-address ] if*
        8 size - swap <displaced-alien>
    ] if
    indirect? [ 0 alien-cell ] when ;

:: va-hppa-address ( cursor layout -- ptr )
    layout aggregate?>> layout size>> 8 > and :> indirect?
    indirect? [ 4 4 ] [
        layout size>> cursor layout va-target-alignment
        layout aggregate?>> layout size>> 4 > and [ 8 max ] when
    ] if :> ( size alignment )
    size 4 align :> slot-size
    cursor stack>> alien-address slot-size -
    alignment 4 max 1 - bitnot bitand <alien> :> base
    cursor base >>stack drop
    slot-size size - base <displaced-alien>
    indirect? [ 0 alien-unsigned-4 <alien> ] when ;

:: va-arg-address ( cursor layout -- ptr )
    cursor check-va-list
    cursor platform>> hppa? [ cursor layout va-hppa-address ] [
    cursor platform>> s390x? [ cursor layout va-s390x-address ] [
        cursor layout va-indirect? :> indirect?
        cursor platform>> aapcs64-va-list-platform? [ cursor layout indirect? va-linux-address ] [
            cursor indirect? [ cursor va-abi-cell dup ] [ layout size>> cursor layout va-target-alignment ] if
            cursor platform>> windows? [ 8 min ] when
            va-stack-address
        ] if
        ! N64 integer scalars occupy the low four bytes of an eight-byte GP slot.
        ! On big endian targets this is the second word. Struct chunks retain
        ! their ABI left justification and start at the unadjusted slot address.
        cursor platform>> mips64? layout aggregate?>> not and [
            cursor platform>> name>> cpu-name-big-endian?
            layout size>> cursor va-abi-cell < and [
                cursor va-abi-cell layout size>> - swap <displaced-alien>
            ] when
        ] when
        indirect? [ 0 alien-cell ] when
    ] if ] if ;

PRIVATE>

MACRO: va-arg ( c-type -- quot: ( cursor -- value ) )
    promote-vararg-type [ <va-layout> ] [ ] bi
    '[ _ va-arg-address 0 _ alien-copy-value ] ;

! ARM64 AAPCS systems use a structured va_list with normal aggregate ABI
! rules. Apple and Windows use a pointer. These are parameter types, not a
! portable void* alias: these systems pass this 32-byte value by
! reference to a copy made by the caller.
STRUCT: native-va-list-storage
    { stack void* }
    { gr-top void* }
    { vr-top void* }
    { gr-offs int }
    { vr-offs int } ;

STRUCT: s390x-va-list-storage
    { gpr-count long }
    { fpr-count long }
    { overflow void* }
    { savearea void* } ;

:: s390x-native-va-list>cursor ( ptr -- cursor )
    ptr 24 alien-cell :> saved
    ptr 16 alien-cell
    56 saved <displaced-alien> 160 saved <displaced-alien>
    ptr 0 alien-signed-8 5 - 0 min -5 max 8 *
    ptr 8 alien-signed-8 4 - 0 min -4 max 8 *
    s390x <platform-va-cursor> ;

:: s390x-cursor>native-va-list ( cursor -- ptr )
    s390x-va-list-storage <struct> :> native
    native
        cursor gr-offs>> 8 /i 5 + >>gpr-count
        cursor vr-offs>> 8 /i 4 + >>fpr-count
        cursor stack>> >>overflow
        -56 cursor gr-top>> <displaced-alien> >>savearea >c-ptr ;

:: native-va-list>cursor ( ptr -- cursor )
    cpu s390x? [ ptr s390x-native-va-list>cursor ] [
        cpu arm.64? cpu riscv? cpu loongarch.64? or or cpu mips? or cpu s390x? or cpu hppa? or [
            os aapcs64-va-list-platform? cpu arm.64? and [
                ptr 0 alien-cell ptr 8 alien-cell ptr 16 alien-cell
                ptr 24 alien-signed-4 ptr 28 alien-signed-4 <va-cursor>
            ] [ ptr f f 0 0 <va-cursor> ] if
        ] [ unsupported-va-list-platform ] if
    ] if ;

:: cursor>native-va-list ( cursor -- ptr )
    cursor check-va-list
    cursor platform>> va-platform = [ unsupported-va-list-platform ] unless
    cpu s390x? [ cursor s390x-cursor>native-va-list ] [
        cpu arm.64? cpu riscv? cpu loongarch.64? or or cpu mips? or cpu s390x? or cpu hppa? or [
            os aapcs64-va-list-platform? cpu arm.64? and [
                native-va-list-storage <struct> :> native
                native
                    cursor stack>> >>stack cursor gr-top>> >>gr-top
                    cursor vr-top>> >>vr-top cursor gr-offs>> >>gr-offs
                    cursor vr-offs>> >>vr-offs >c-ptr
            ] [ cursor stack>> ] if
        ] [ unsupported-va-list-platform ] if
    ] if ;

SYMBOL: va_list

[
    cpu arm.64? cpu riscv? cpu loongarch.64? or or cpu mips? or cpu s390x? or cpu hppa? or [
        os aapcs64-va-list-platform? cpu arm.64? and [ native-va-list-storage ] [ void* ] if
        lookup-c-type clone
            va-cursor >>boxed-class
            [ native-va-list>cursor ] >>boxer-quot
            [ cursor>native-va-list ] >>unboxer-quot
        va_list typedef
    ] [ void* va_list typedef ] if
] with-compilation-unit

: native-va-list-type? ( type -- ? )
    cpu arm.64? cpu riscv? cpu loongarch.64? or or cpu mips? or cpu s390x? or cpu hppa? or [
        dup abstract-c-type? [ lookup-c-type ] unless
        va_list lookup-c-type eq?
    ] [ drop f ] if ;
