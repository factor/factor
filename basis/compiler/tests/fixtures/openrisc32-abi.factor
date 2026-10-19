! Independent C callers and callees are in vm/ffi_test_openrisc.c.
USING: accessors alien alien.c-types alien.libraries alien.syntax
classes.struct combinators compiler.test destructors io.pathnames kernel locals
math math.bitwise system tools.test ;
IN: compiler.tests.openrisc32-abi

<< "openrisc-abi" "resource:libfactor-ffi-test.so" absolute-path cdecl add-library >>
LIBRARY: openrisc-abi

STRUCT: or1k-abi-pair { high uint } { low uint } ;
STRUCT: or1k-abi-triple { first uint } { second uint } { third uint } ;

: <or1k-abi-pair> ( high low -- value )
    or1k-abi-pair <struct> swap >>low swap >>high ;
: <or1k-abi-triple> ( first second third -- value )
    or1k-abi-triple <struct> swap >>third swap >>second swap >>first ;

FUNCTION: ulonglong or1k_abi_u64
    ( uint tag, ulonglong first, uint tail, ulonglong second )
FUNCTION: ulonglong or1k_abi_stack_u64
    ( uint a0, uint a1, uint a2, uint a3, uint a4,
      ulonglong wide, uint tail )
FUNCTION: double or1k_abi_doubles
    ( uint tag, double first, double second, uint tail )
FUNCTION: ulonglong or1k_abi_take_pair
    ( or1k-abi-pair value, uint tail )
FUNCTION: or1k-abi-pair or1k_abi_return_pair ( uint high, uint low )
FUNCTION: or1k-abi-triple or1k_abi_transform_triple
    ( or1k-abi-triple value, uint delta )
FUNCTION-ALIAS: or1k-varargs double or1k_abi_varargs
    ( uint tag, double named, ... uint tail, double floating, ulonglong wide )
FUNCTION: ulonglong or1k_abi_call_u64 ( void* callback )
FUNCTION: ulonglong or1k_abi_call_pair ( void* callback )
FUNCTION: ulonglong or1k_abi_call_return_pair ( void* callback )
FUNCTION: ulonglong or1k_abi_call_triple ( void* callback )

: or1k-u64-callback ( -- callback )
    ulonglong { uint ulonglong uint ulonglong } cdecl
    [| tag first tail second |
        first second tag 32 shift tail bitor + bitxor
    ] alien-callback ;
: or1k-pair-callback ( -- callback )
    ulonglong { or1k-abi-pair uint } cdecl
    [| value tail | value high>> 32 shift value low>> bitor tail bitxor ]
    alien-callback ;
: or1k-return-pair-callback ( -- callback )
    or1k-abi-pair { uint uint } cdecl
    [| high low |
        high 0x13579bdf bitxor low 0x2468ace0 bitxor <or1k-abi-pair>
    ] alien-callback ;
: or1k-triple-callback ( -- callback )
    or1k-abi-triple { or1k-abi-triple uint } cdecl
    [| value delta |
        value first>> delta +
        value second>> delta bitxor
        value third>> delta - <or1k-abi-triple>
    ] alien-callback ;

cpu openrisc.32? [
    { 0x1fded99d42628568 } [
        0x10203040 0x1122334455667788 0xa0b0c0d0
        0xfedcba9876543210 or1k_abi_u64
    ] unit-test
    { 0x89abcdf0548910cd } [
        1 2 4 8 16 0x89abcdef01234567 0x55aa55aa or1k_abi_stack_u64
    ] unit-test
    { 6.5 } [ 3 1.25 -2.5 11 or1k_abi_doubles ] unit-test
    { 0x12345678cf168b5a } [
        0x12345678 0x9abcdef0 <or1k-abi-pair> 0x55aa55aa
        or1k_abi_take_pair
    ] unit-test
    { 0x0163cda7 0xbed47210 } [
        0x12345678 0x9abcdef0 or1k_abi_return_pair
        [ high>> ] [ low>> ] bi
    ] unit-test
    { 17 19 23 } [
        10 20 30 <or1k-abi-triple> 7 or1k_abi_transform_triple
        [ first>> ] [ second>> ] [ third>> ] tri
    ] unit-test
    { 18.5 } [
        3 1.25 11 -2.5 0x0000000500000007 or1k-varargs
    ] unit-test

    { 0x1fded99d42628568 } [
        or1k-u64-callback [ or1k_abi_call_u64 ] with-callback
    ] unit-test
    { 0x12345678cf168b5a } [
        or1k-pair-callback [ or1k_abi_call_pair ] with-callback
    ] unit-test
    { 0x0163cda7bed47210 } [
        or1k-return-pair-callback [ or1k_abi_call_return_pair ] with-callback
    ] unit-test
    { 0x0000001100130017 } [
        or1k-triple-callback [ or1k_abi_call_triple ] with-callback
    ] unit-test
] when
