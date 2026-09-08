! Copyright (C) 2026 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.accessors alien.arrays alien.c-types
alien.c-types.varargs alien.data alien.private arrays byte-arrays
classes.struct combinators combinators.short-circuit continuations
cpu.architecture cpu.arm.64.abi grouping kernel libc locals math math.order
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

: <va-cursor> ( stack gr-top vr-top gr-offs vr-offs -- cursor )
    cpu arm.64? [ os <platform-va-cursor> ] [ unsupported-va-list-platform ] if ;

: check-va-list ( cursor -- )
    lifetime>> {
        [ active?>> ] [ callback>> current-callback = ] [ thread>> self eq? ]
    } 1&&
    [ expired-va-list ] unless ;

: va-copy ( cursor -- copy ) dup check-va-list clone ;

<PRIVATE

! Metadata is compiled once for each literal va-arg type. The platform
! distinction is made by the reader so synthetic ABI tests can run anywhere.
TUPLE: va-layout size alignment members aggregate? homogeneous? ;

:: <va-layout> ( type -- layout )
    type lookup-c-type :> resolved
    resolved homogeneous-aggregate-members :> members
    va-layout new
        type heap-size >>size type c-type-align >>alignment
        members [ ] [ { } ] if* >>members resolved struct-c-type? >>aggregate?
        members >boolean >>homogeneous? ;

: align-va-pointer ( ptr alignment -- ptr' )
    [ alien-address ] dip align <alien> ;

:: va-stack-address ( cursor size alignment -- ptr )
    cursor stack>> alignment 8 max align-va-pointer :> ptr
    cursor size 8 align ptr <displaced-alien> >>stack drop
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
    layout aggregate?>> layout size>> 16 > and
    cursor platform>> windows? layout homogeneous?>> not or and ;

:: va-linux-address ( cursor layout indirect? -- ptr )
    indirect? [ 8 8 ] [ layout size>> layout alignment>> ] if :> ( size alignment )
    layout homogeneous?>> indirect? not and [
        cursor layout members>> length va-vr-address [
            layout aggregate?>> [ layout reassemble-va-hfa ] when
        ] [ cursor size alignment va-stack-address ] if*
    ] [
        cursor size alignment va-gpr-address
        [ ] [ cursor size alignment va-stack-address ] if*
    ] if ;

:: va-arg-address ( cursor layout -- ptr )
    cursor check-va-list
    cursor layout va-indirect? :> indirect?
    cursor platform>> linux? [ cursor layout indirect? va-linux-address ] [
        cursor indirect? [ 8 8 ] [ layout size>> layout alignment>> ] if
        cursor platform>> windows? [ 8 min ] when
        va-stack-address
    ] if
    indirect? [ 0 alien-cell ] when ;

PRIVATE>

MACRO: va-arg ( c-type -- quot: ( cursor -- value ) )
    promote-vararg-type [ <va-layout> ] [ ] bi
    '[ _ va-arg-address 0 _ alien-copy-value ] ;

! Linux's va_list is a structure passed according to normal aggregate ABI
! rules. Apple and Windows use a pointer. These are parameter types, not a
! portable void* alias: in particular, Linux passes this 32-byte value by
! reference to a copy made by the caller.
STRUCT: native-va-list-storage
    { stack void* }
    { gr-top void* }
    { vr-top void* }
    { gr-offs int }
    { vr-offs int } ;

:: native-va-list>cursor ( ptr -- cursor )
    cpu arm.64? [
        os linux? [
            ptr 0 alien-cell ptr 8 alien-cell ptr 16 alien-cell
            ptr 24 alien-signed-4 ptr 28 alien-signed-4 <va-cursor>
        ] [ ptr f f 0 0 <va-cursor> ] if
    ] [ unsupported-va-list-platform ] if ;

:: cursor>native-va-list ( cursor -- ptr )
    cursor check-va-list
    cursor platform>> os = [ unsupported-va-list-platform ] unless
    cpu arm.64? [
        os linux? [
            native-va-list-storage <struct> :> native
            native
                cursor stack>> >>stack cursor gr-top>> >>gr-top
                cursor vr-top>> >>vr-top cursor gr-offs>> >>gr-offs
                cursor vr-offs>> >>vr-offs >c-ptr
        ] [ cursor stack>> ] if
    ] [ unsupported-va-list-platform ] if ;

SYMBOL: va_list

cpu arm.64? [
    os linux? [ native-va-list-storage ] [ void* ] if
    lookup-c-type clone
        va-cursor >>boxed-class
        [ native-va-list>cursor ] >>boxer-quot
        [ cursor>native-va-list ] >>unboxer-quot
    va_list typedef
] [ void* va_list typedef ] if

: native-va-list-type? ( type -- ? )
    cpu arm.64? [
        dup abstract-c-type? [ lookup-c-type ] unless
        va_list lookup-c-type eq?
    ] [ drop f ] if ;
