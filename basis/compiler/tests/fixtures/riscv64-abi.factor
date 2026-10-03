! Independent C compiler callers and callees are in vm/ffi_test_riscv.c.
USING: accessors alien alien.accessors alien.c-types alien.libraries alien.syntax arrays
byte-arrays
classes.struct combinators compiler.test destructors io.pathnames kernel locals math
memory sequences tools.test unix.linux.epoll unix.statvfs.linux
unix.types vocabs.loader ;
FROM: alien.c-types => float ;
IN: compiler.tests.riscv64-abi

<< "riscv-abi" "resource:libfactor-ffi-test.so" absolute-path cdecl add-library >>
LIBRARY: riscv-abi

STRUCT: bit-fp { bits uint bits: 3 } { number double } ;
PACKED-STRUCT: fp-bit { number float } { bits int bits: 13 } ;
STRUCT: fp-pair { a float } { b double } ;

: <bit-fp> ( bits number -- value ) bit-fp <struct> swap >>number swap >>bits ;
: <fp-bit> ( number bits -- value ) fp-bit <struct> swap >>bits swap >>number ;
: <fp-pair> ( a b -- value ) fp-pair <struct> swap >>b swap >>a ;

FUNCTION: double rv_take_bit_fp ( bit-fp value, long tail )
FUNCTION: bit-fp rv_return_bit_fp ( uint bits, double number )
FUNCTION: double rv_call_bit_fp ( void* callback )
FUNCTION: double rv_call_return_bit_fp ( void* callback )
FUNCTION: double rv_take_fp_bit ( fp-bit value, long tail )
FUNCTION: fp-bit rv_return_fp_bit ( float number, int bits )
FUNCTION: double rv_call_fp_bit ( void* callback )
FUNCTION: double rv_call_return_fp_bit ( void* callback )
FUNCTION: size_t rv_sizeof_nlink_t ( )
FUNCTION: size_t rv_sizeof_blksize_t ( )
FUNCTION: size_t rv_sizeof_epoll_event ( )
FUNCTION: size_t rv_offsetof_epoll_data ( )
FUNCTION: size_t rv_sizeof_statvfs ( )
FUNCTION: size_t rv_offsetof_statvfs_flag ( )
FUNCTION: size_t rv_offsetof_statvfs_namemax ( )
FUNCTION: ulong rv_statvfs_flag ( c-string path )
FUNCTION: ulong rv_statvfs_namemax ( c-string path )
FUNCTION: long rv_call_stack_gc ( void* callback,
    long a0, long a1, long a2, long a3, long a4,
    long a5, long a6, long a7, long a8 )
FUNCTION: double rv_fp_pair_after_stack (
    long a0, long a1, long a2, long a3, long a4,
    long a5, long a6, long a7, long a8, long a9, fp-pair value )
FUNCTION: double rv_call_fp_pair_after_stack ( void* callback )

{ t } [ nlink_t heap-size rv_sizeof_nlink_t = ] unit-test
{ t } [ blksize_t heap-size rv_sizeof_blksize_t = ] unit-test
{ t } [ epoll-event heap-size rv_sizeof_epoll_event = ] unit-test
{ t } [
    epoll-event lookup-c-type fields>> second offset>> rv_offsetof_epoll_data =
] unit-test

{ t } [ \ statvfs64 heap-size rv_sizeof_statvfs = ] unit-test
{ t } [ "f_flag" \ statvfs64 offset-of rv_offsetof_statvfs_flag = ] unit-test
{ t } [ "f_namemax" \ statvfs64 offset-of rv_offsetof_statvfs_namemax = ] unit-test
{ t t } [
    \ statvfs64 new "/" over statvfs64 0 assert=
    [ f_flag>> "/" rv_statvfs_flag = ]
    [ f_namemax>> "/" rv_statvfs_namemax = ] bi
] unit-test

{ 23.0 } [ 7 2.5 <bit-fp> 11 rv_take_bit_fp ] unit-test
{ 5 -3.0 } [ 5 -3.0 rv_return_bit_fp [ bits>> ] [ number>> ] bi ] unit-test
{ -2031.0 } [ 2.5 -2047 <fp-bit> 11 rv_take_fp_bit ] unit-test
{ -3.0 -4095 } [ -3.0 -4095 rv_return_fp_bit [ number>> ] [ bits>> ] bi ] unit-test

: indirect-bit-fp ( value tail pointer -- result )
    double { bit-fp long } cdecl alien-indirect ;
: indirect-fp-bit ( value tail pointer -- result )
    double { fp-bit long } cdecl alien-indirect ;
{ 23.0 } [
    7 2.5 <bit-fp> 11 "rv_take_bit_fp" "riscv-abi" library-dll dlsym indirect-bit-fp
] unit-test
{ -2031.0 } [
    2.5 -2047 <fp-bit> 11 "rv_take_fp_bit" "riscv-abi" library-dll dlsym indirect-fp-bit
] unit-test

: bit-fp-callback ( -- callback )
    double { bit-fp long } cdecl
    [| value tail | value bits>> value number>> 2 * + tail + ] alien-callback ;
: fp-bit-callback ( -- callback )
    double { fp-bit long } cdecl
    [| value tail | value bits>> value number>> 2 * + tail + ] alien-callback ;
: return-bit-fp-callback ( -- callback )
    bit-fp { uint double } cdecl [ <bit-fp> ] alien-callback ;
: return-fp-bit-callback ( -- callback )
    fp-bit { float int } cdecl [ <fp-bit> ] alien-callback ;

{ 23.0 } [ bit-fp-callback [ rv_call_bit_fp ] with-callback ] unit-test
{ -2031.0 } [ fp-bit-callback [ rv_call_fp_bit ] with-callback ] unit-test
{ -1.0 } [ return-bit-fp-callback [ rv_call_return_bit_fp ] with-callback ] unit-test
{ -4101.0 } [ return-fp-bit-callback [ rv_call_return_fp_bit ] with-callback ] unit-test

! Integer stack arguments leave the independent floating-point bank free.
{ 51.5 } [
    1 2 3 4 5 6 7 8 9 10 2.5 -3.0 <fp-pair> rv_fp_pair_after_stack
] unit-test
: fp-pair-after-stack-callback ( -- callback )
    double { long long long long long long long long long long fp-pair }
    cdecl [| a0 a1 a2 a3 a4 a5 a6 a7 a8 a9 value |
        a0 a1 + a2 + a3 + a4 + a5 + a6 + a7 + a8 + a9 +
        value a>> + value b>> 2 * +
    ] alien-callback ;
{ 51.5 } [
    fp-pair-after-stack-callback [ rv_call_fp_pair_after_stack ] with-callback
] unit-test

! Keep a tagged register live across a foreign call whose arguments spill
! to the native stack, then compact the heap from its callback.
: compact-callback ( -- callback )
    void { } cdecl [ 4096 7 <array> compact-gc sum drop ] alien-callback ;
:: stack-call-with-root ( root callback -- root result )
    callback 1 2 3 4 5 6 7 8 9 rv_call_stack_gc :> result
    root result ;
: indirect-stack-call ( callback pointer -- result )
    [ 1 2 3 4 5 6 7 8 9 ] dip
    long { void* long long long long long long long long long }
    cdecl alien-indirect ;
:: indirect-stack-call-with-root ( root callback pointer -- root result )
    callback pointer indirect-stack-call :> result
    root result ;
:: stack-call-with-buffer ( buffer callback -- result )
    buffer 0 alien-unsigned-1 :> first-byte
    callback 1 2 3 4 5 6 7 8 9 rv_call_stack_gc drop
    first-byte buffer 1 alien-unsigned-1 + ;
:: indirect-stack-call-with-buffer ( buffer callback pointer -- result )
    buffer 0 alien-unsigned-1 :> first-byte
    callback pointer indirect-stack-call drop
    first-byte buffer 1 alien-unsigned-1 + ;

{ 101 12423 45 } [
    compact-callback [
        101 123 <array> swap stack-call-with-root
        [ [ length ] [ sum ] bi ] dip
    ] with-callback
] unit-test
{ 30 } [
    compact-callback [ B{ 10 20 } clone swap stack-call-with-buffer ] with-callback
] unit-test
{ 30 } [
    compact-callback [
        B{ 10 20 } clone swap
        "rv_call_stack_gc" "riscv-abi" library-dll dlsym
        indirect-stack-call-with-buffer
    ] with-callback
] unit-test
{ 101 12423 45 } [
    compact-callback [
        101 123 <array> swap
        "rv_call_stack_gc" "riscv-abi" library-dll dlsym
        indirect-stack-call-with-root [ [ length ] [ sum ] bi ] dip
    ] with-callback
] unit-test

! Both backends can be present after load-all. Compile fresh native calls and
! callbacks after each load order; the C oracle independently reads signed bits.
: signed-bitfield-abi-roundtrip ( -- taken number bits callback returned )
    2.5 -2047 <fp-bit> 11 rv_take_fp_bit
    -3.0 -4095 rv_return_fp_bit [ number>> ] [ bits>> ] bi
    double { fp-bit long } cdecl
    [| value tail | value bits>> value number>> 2 * + tail + ] alien-callback
    [ rv_call_fp_bit ] with-callback
    fp-bit { float int } cdecl [ <fp-bit> ] alien-callback
    [ rv_call_return_fp_bit ] with-callback ; inline

{ -2031.0 -3.0 -4095 -2031.0 -4101.0 } [
    { "cpu.riscv.32.abi" "cpu.riscv.64.abi" } [ reload ] each
    [ signed-bitfield-abi-roundtrip ] compile-call
] unit-test
{ -2031.0 -3.0 -4095 -2031.0 -4101.0 } [
    { "cpu.riscv.64.abi" "cpu.riscv.32.abi" } [ reload ] each
    [ signed-bitfield-abi-roundtrip ] compile-call
] unit-test
