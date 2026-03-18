USING: accessors alien.c-types arrays bit-arrays byte-arrays
classes.struct compiler.cfg compiler.cfg.instructions
compiler.cfg.stack-frame compiler.cfg.utilities
compiler.codegen.gc-maps compiler.codegen.relocation
cpu.architecture kernel layouts make math namespaces sequences
specialized-arrays system tools.test ;
QUALIFIED: vm
SPECIALIZED-ARRAY: uint
IN: compiler.codegen.gc-maps.tests

SINGLETON: fake-cpu

fake-cpu \ cpu set

M: fake-cpu gc-root-offset ;

[
    init-relocation
    V{ } clone return-addresses set
    V{ } clone gc-maps set

    50 <byte-array> %

    <gc-map> gc-map-here

    50 <byte-array> %

    T{ gc-map
       { gc-roots V{ 1 3 } }
       { derived-roots V{ { 2 4 } } }
    } gc-map-here
    emit-gc-maps
] B{ } make
"result" set

{ 0 } [ "result" get length 16 mod ] unit-test

[
    100 <byte-array> %

    ! The below data is 29 bytes -- 15 bytes padding needed to
    ! align
    15 <byte-array> %

    ! Bitmap - 1 byte
    ?{
        ! gc-roots
        f t f t
    } underlying>> %

    ! Derived pointers - 12 bytes
    uint-array{ -1 -1 4 } underlying>> %

    ! Return addresses - 4 bytes
    uint-array{ 100 } underlying>> %

    ! GC info footer - 12 bytes
    S{ vm:gc-info
       { gc-root-count 4 }
       { derived-root-count 3 }
       { return-address-count 1 }
    } (underlying)>> %
] B{ } make
"expect" set

{ t } [ "result" get length "expect" get length = ] unit-test
{ t } [ "result" get "expect" get = ] unit-test

! largest-spill-slot
{
    5 0 4 1
} [
    { { 4 } } largest-spill-slot
    { { } } largest-spill-slot
    { { 2 3 } { 0 } } largest-spill-slot
    { { 0 } } largest-spill-slot
] unit-test

! gc-map-needed?
{ f } [
    T{ gc-map } gc-map-needed?
] unit-test

! emit-gc-info-bitmap
{
    0 V{ }
} [
    { T{ gc-map } } [ emit-gc-info-bitmap ] V{ } make
] unit-test

! ! derived-root-offsets
{
    V{ { 2 4 } }
} [
    T{ gc-map { derived-roots V{ { 2 4 } } } }
    derived-root-offsets
] unit-test

! emit-base-tables
{
    3 B{ 255 255 255 255 255 255 255 255 4 0 0 0 }
} [
    { T{ gc-map { derived-roots V{ { 2 4 } } } } }
    [ emit-base-tables ] B{ } make
] unit-test

! serialize-gc-maps
{
    B{ 0 0 0 0 }
} [
    { } return-addresses set serialize-gc-maps
] unit-test

{
    B{ 123 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 }
} [
    { 123 } return-addresses set
    { T{ gc-map } } gc-maps set
    serialize-gc-maps
] unit-test

! gc-info + ret-addr + 9bits (5+2+2) = 20 + 4 + 2 = 26
{ 17 } [
    {
        T{ gc-map
           { gc-roots V{ 1 3 } }
        }
    } gc-maps set
    { 123 } return-addresses set
    serialize-gc-maps length
] unit-test

! gc-info + ret-addr + 3 base-pointers + 9bits = 20 + 4 + 12 + 2 = 38
{ 29 } [
    {
        T{ gc-map
           { gc-roots V{ 1 3 } }
           { derived-roots V{ { 2 4 } } }
        }
    } gc-maps set
    { 123 } return-addresses set
    serialize-gc-maps length
] unit-test
