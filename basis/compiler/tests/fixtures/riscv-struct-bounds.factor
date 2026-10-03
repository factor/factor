! Independent callers and guarded allocations are in vm/ffi_test_riscv.c.
USING: accessors alien alien.accessors alien.c-types alien.destructors alien.libraries
alien.syntax classes.struct combinators continuations destructors io.pathnames kernel
locals math namespaces sequences tools.test ;
IN: compiler.tests.riscv-struct-bounds

<< "riscv-bounds" "resource:libfactor-ffi-test.so" absolute-path cdecl add-library >>
LIBRARY: riscv-bounds

PACKED-STRUCT: bytes3 { bytes uchar[3] } ;
PACKED-STRUCT: bytes5 { bytes uchar[5] } ;
PACKED-STRUCT: bytes9 { bytes uchar[9] } ;
PACKED-STRUCT: bytes17 { bytes uchar[17] } ;

FUNCTION: void* rv_guard_alloc ( size_t size )
FUNCTION: void rv_guard_free ( void* pointer )
DESTRUCTOR: rv_guard_free
FUNCTION: uint rv_take_bytes3 ( bytes3 value )
FUNCTION: uint rv_take_bytes5 ( bytes5 value )
FUNCTION: uint rv_take_bytes9 ( bytes9 value )
FUNCTION: uint rv_take_bytes17 ( bytes17 value )
FUNCTION: bytes3 rv_return_bytes3 ( )
FUNCTION: bytes5 rv_return_bytes5 ( )
FUNCTION: bytes9 rv_return_bytes9 ( )
FUNCTION: bytes17 rv_return_bytes17 ( )
FUNCTION: uint rv_call_bytes3 ( void* callback, void* pointer )
FUNCTION: uint rv_call_bytes5 ( void* callback, void* pointer )
FUNCTION: uint rv_call_bytes9 ( void* callback, void* pointer )
FUNCTION: uint rv_call_bytes17 ( void* callback, void* pointer )
FUNCTION: uint rv_call_return_bytes3 ( void* callback )
FUNCTION: uint rv_call_return_bytes5 ( void* callback )
FUNCTION: uint rv_call_return_bytes9 ( void* callback )
FUNCTION: uint rv_call_return_bytes17 ( void* callback )
FUNCTION: void rv_call_guarded_return ( void* callback, void* pointer )

: <guarded-bytes> ( size -- pointer )
    rv_guard_alloc dup f = f assert=
    &rv_guard_free ;

! Include register arguments, two-register aggregates and indirect copies.
! A C callee's mutation of its by-value argument must leave the source intact.
{ 6 1 } [
    [ 3 <guarded-bytes>
        [ bytes3 memory>struct rv_take_bytes3 ] [ 0 alien-unsigned-1 ] bi
    ] with-destructors
] unit-test
{ 15 1 } [
    [ 5 <guarded-bytes>
        [ bytes5 memory>struct rv_take_bytes5 ] [ 0 alien-unsigned-1 ] bi
    ] with-destructors
] unit-test
{ 45 1 } [
    [ 9 <guarded-bytes>
        [ bytes9 memory>struct rv_take_bytes9 ] [ 0 alien-unsigned-1 ] bi
    ] with-destructors
] unit-test
{ 153 1 } [
    [ 17 <guarded-bytes>
        [ bytes17 memory>struct rv_take_bytes17 ] [ 0 alien-unsigned-1 ] bi
    ] with-destructors
] unit-test

: indirect-bytes17 ( value pointer -- sum )
    uint { bytes17 } cdecl alien-indirect ;
{ 153 } [
    [ 17 <guarded-bytes> bytes17 memory>struct
        "rv_take_bytes17" "riscv-bounds" library-dll dlsym indirect-bytes17
    ] with-destructors
] unit-test

{ 6 } [ rv_return_bytes3 bytes>> sum ] unit-test
{ 15 } [ rv_return_bytes5 bytes>> sum ] unit-test
{ 45 } [ rv_return_bytes9 bytes>> sum ] unit-test
{ 153 } [ rv_return_bytes17 bytes>> sum ] unit-test

: bytes3-callback ( -- callback )
    uint { bytes3 } cdecl [ bytes>> sum ] alien-callback ;
: bytes5-callback ( -- callback )
    uint { bytes5 } cdecl [ bytes>> sum ] alien-callback ;
: bytes9-callback ( -- callback )
    uint { bytes9 } cdecl [ bytes>> sum ] alien-callback ;
: bytes17-callback ( -- callback )
    uint { bytes17 } cdecl [ bytes>> sum ] alien-callback ;

{ 6 } [
    [ bytes3-callback
        [ 3 <guarded-bytes> rv_call_bytes3 ] with-callback
    ] with-destructors
] unit-test
{ 15 } [
    [ bytes5-callback
        [ 5 <guarded-bytes> rv_call_bytes5 ] with-callback
    ] with-destructors
] unit-test
{ 45 } [
    [ bytes9-callback
        [ 9 <guarded-bytes> rv_call_bytes9 ] with-callback
    ] with-destructors
] unit-test
{ 153 } [
    [ bytes17-callback
        [ 17 <guarded-bytes> rv_call_bytes17 ] with-callback
    ] with-destructors
] unit-test

! Returning a view of foreign memory also needs an exact-size source read.
SYMBOL: callback-source

! Callbacks enter a fresh Factor context, so pass the source through the global
! namespace and restore it when the C call finishes.
:: with-callback-source ( pointer quot -- )
    callback-source get-global :> previous
    pointer callback-source set-global
    [ quot call ] [ previous callback-source set-global ] finally ; inline

: return-bytes3-callback ( -- callback )
    bytes3 { } cdecl [ callback-source get-global bytes3 memory>struct ] alien-callback ;
: return-bytes5-callback ( -- callback )
    bytes5 { } cdecl [ callback-source get-global bytes5 memory>struct ] alien-callback ;
: return-bytes9-callback ( -- callback )
    bytes9 { } cdecl [ callback-source get-global bytes9 memory>struct ] alien-callback ;
: return-bytes17-callback ( -- callback )
    bytes17 { } cdecl [ callback-source get-global bytes17 memory>struct ] alien-callback ;

{ 6 } [
    [ 3 <guarded-bytes> [
        return-bytes3-callback [ rv_call_return_bytes3 ] with-callback
    ] with-callback-source
    ] with-destructors
] unit-test
{ 15 } [
    [ 5 <guarded-bytes> [
        return-bytes5-callback [ rv_call_return_bytes5 ] with-callback
    ] with-callback-source
    ] with-destructors
] unit-test
{ 45 } [
    [ 9 <guarded-bytes> [
        return-bytes9-callback [ rv_call_return_bytes9 ] with-callback
    ] with-callback-source
    ] with-destructors
] unit-test
{ 153 } [
    [ 17 <guarded-bytes> [
        return-bytes17-callback [ rv_call_return_bytes17 ] with-callback
    ] with-callback-source
    ] with-destructors
] unit-test

! The C oracle supplies the lowered hidden a0 destination at a guard page.
! Both the source and destination contain exactly 17 bytes.
{ 153 } [
    [| |
        17 <guarded-bytes> :> source
        17 <guarded-bytes> :> destination
        source [
            return-bytes17-callback
            [ destination rv_call_guarded_return ] with-callback
        ] with-callback-source
        destination bytes17 memory>struct bytes>> sum
    ] with-destructors
] unit-test
