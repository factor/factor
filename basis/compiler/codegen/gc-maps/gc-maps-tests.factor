USING: accessors alien.c-types arrays bit-arrays classes.struct compiler.cfg
compiler.cfg.instructions compiler.cfg.stack-frame compiler.cfg.utilities
compiler.codegen.gc-maps compiler.codegen.relocation cpu.architecture
cpu.x86 byte-arrays make namespaces kernel layouts math sequences
specialized-arrays system tools.test ;
QUALIFIED: vm
SPECIALIZED-ARRAY: uint
IN: compiler.codegen.gc-maps.tests

SINGLETON: fake-cpu

fake-cpu \ cpu set

M: fake-cpu gc-root-offset ;

[
    init-relocation
    init-gc-maps

    50 <byte-array> %

    <gc-map> gc-map-here

    50 <byte-array> %

    T{ gc-map
       { scrub-d { 0 1 1 1 0 } }
       { scrub-r { 1 0 } }
       { gc-roots V{ 1 3 } }
       { derived-roots V{ { 2 4 } } }
    } gc-map-here
    emit-gc-maps
] B{ } make
"result" set

{ 0 } [ "result" get length 16 mod ] unit-test

[
    100 <byte-array> %

    ! The below data is 38 bytes -- 6 bytes padding needed to
    ! align
    6 <byte-array> %

    ! Bitmap - 2 bytes
    ?{
        ! scrub-d
        t f f f t
        ! scrub-r
        f t
        ! gc-roots
        f t f t
    } underlying>> %

    ! Derived pointers
    uint-array{ -1 -1 4 } underlying>> %

    ! Return addresses
    uint-array{ 100 } underlying>> %

    ! GC info footer - 20 bytes
    S{ vm:gc-info
       { scrub-d-count 5 }
       { scrub-r-count 2 }
       { gc-root-count 4 }
       { derived-root-count 3 }
       { return-address-count 1 }
    } (underlying)>> %
] B{ } make
"expect" set

{ t } [ "result" get length "expect" get length = ] unit-test
{ t } [ "result" get "expect" get = ] unit-test

! Fix the gc root offset calculations
SINGLETON: linux-x86.64
M: linux-x86.64 reserved-stack-space 0 ;
M: linux-x86.64 gc-root-offset
    n>> spill-offset cell + cell /i ;

: cfg-w-spill-area-base ( base -- cfg )
    stack-frame new swap >>spill-area-base
    { } insns>cfg swap >>stack-frame ;

cpu x86.64? [
    linux-x86.64 \ cpu set

    ! gc-root-offsets
    { { 1 3 } } [
        0 cfg-w-spill-area-base cfg [
            T{ gc-map
               { gc-roots {
                   T{ spill-slot { n 0 } }
                   T{ spill-slot { n 16 } }
               } }
            } gc-root-offsets
        ] with-variable
    ] unit-test

    { { 6 10 } } [
        32 cfg-w-spill-area-base cfg [
            T{ gc-map
               { gc-roots {
                   T{ spill-slot { n 8 } }
                   T{ spill-slot { n 40 } }
               } }
            } gc-root-offsets
        ] with-variable
    ] unit-test

    ! scrub-d scrub-r gc-roots
    { { 0 0 5 } } [
        0 cfg-w-spill-area-base cfg [
            T{ gc-map
               { gc-roots {
                   T{ spill-slot { n 0 } }
                   T{ spill-slot { n 24 } }
               } }
            } 1array
            [ emit-gc-info-bitmaps ] B{ } make drop
        ] with-variable
    ] unit-test

    ! scrub-d scrub-r gc-roots
    { { 0 0 9 } } [
        32 cfg-w-spill-area-base cfg [
            T{ gc-map
               { gc-roots {
                   T{ spill-slot { n 0 } }
                   T{ spill-slot { n 24 } }
               } }
            } 1array
            [ emit-gc-info-bitmaps ] B{ } make drop
        ] with-variable
    ] unit-test

    fake-cpu \ cpu set
] when

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
{ t t } [
    T{ gc-map { scrub-d { 0 1 1 1 0 } } { scrub-r { 1 0 } } } gc-map-needed?
    T{ gc-map { scrub-d { 0 1 1 1 } } } gc-map-needed?
] unit-test

! emit-scrub
{ 3 V{ t t t f f f } } [
    [ { { 0 0 0 } { 1 1 1 } } emit-scrub ] V{ } make
] unit-test

! emit-gc-info-bitmaps
{
    { 4 2 0 }
    V{ 1 }
} [
    { T{ gc-map { scrub-d { 0 1 1 1 } } { scrub-r { 1 1 } } } }
    [ emit-gc-info-bitmaps ] V{ } make
] unit-test

{
    { 1 0 0 }
    V{ 1 }
} [
    { T{ gc-map { scrub-d { 0 } } } }
    [ emit-gc-info-bitmaps ] V{ } make
] unit-test

! derived-root-offsets
USING: present prettyprint ;
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
    B{ 17 123 0 0 0 5 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 }
} [
    { 123 } return-addresses set
    { T{ gc-map { scrub-d { 0 1 1 1 0 } } } } gc-maps set
    serialize-gc-maps
] unit-test

! gc-info + ret-addr + 9bits (5+2+2) = 20 + 4 + 2 = 26
{ 26 } [
    {
        T{ gc-map
           { scrub-d { 0 1 1 1 0 } }
           { scrub-r { 1 0 } }
           { gc-roots V{ 1 3 } }
        }
    } gc-maps set
    { 123 } return-addresses set
    serialize-gc-maps length
] unit-test

! gc-info + ret-addr + 3 base-pointers + 9bits = 20 + 4 + 12 + 2 = 38
{ 38 } [
    {
        T{ gc-map
           { scrub-d { 0 1 1 1 0 } }
           { scrub-r { 1 0 } }
           { gc-roots V{ 1 3 } }
           { derived-roots V{ { 2 4 } } }
        }
    } gc-maps set
    { 123 } return-addresses set
    serialize-gc-maps length
] unit-test
