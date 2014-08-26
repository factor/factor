USING: namespaces byte-arrays make compiler.codegen.gc-maps
compiler.codegen.relocation bit-arrays accessors classes.struct
tools.test kernel math sequences alien.c-types
specialized-arrays boxes compiler.cfg.instructions system
cpu.architecture vm ;
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

[ 0 ] [ "result" get length 16 mod ] unit-test

[
    100 <byte-array> %

    ! The below data is 46 bytes -- 14 bytes padding needed to
    ! align
    14 <byte-array> %

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

    ! GC info footer - 28 bytes
    S{ gc-info
       { scrub-d-count 5 }
       { scrub-r-count 2 }
       { check-d-count 0 }
       { check-r-count 0 }
       { gc-root-count 4 }
       { derived-root-count 3 }
       { return-address-count 1 }
    } (underlying)>> %
] B{ } make
"expect" set

[ t ] [ "result" get length "expect" get length = ] unit-test
[ t ] [ "result" get "expect" get = ] unit-test

! gc-map-needed?
{ t t } [
    T{ gc-map { scrub-d { 0 1 1 1 0 } } { scrub-r { 1 0 } } } gc-map-needed?
    T{ gc-map { check-d { 0 1 1 1 } } } gc-map-needed?
] unit-test

! emit-scrub
{ 3 V{ t t t f f f } } [
    [ { { 0 0 0 } { 1 1 1 } } emit-scrub ] V{ } make
] unit-test

! emit-gc-info-bitmaps
{
    { 4 2 0 0 0 }
    V{ 1 }
} [
    { T{ gc-map { scrub-d { 0 1 1 1 } } { scrub-r { 1 1 } } } } gc-maps set
    [ emit-gc-info-bitmaps ] V{ } make
] unit-test

{
    { 1 0 1 0 0 }
    V{ 3 }
} [
    { T{ gc-map { scrub-d { 0 } } { check-d { 0 } } } } gc-maps set
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
    { T{ gc-map { derived-roots V{ { 2 4 } } } } } gc-maps set
    [ emit-base-tables ] B{ } make
] unit-test


! serialize-gc-maps
{
    B{ 0 0 0 0 }
} [
    { } return-addresses set serialize-gc-maps
] unit-test

{
    B{
        17 123 0 0 0 5 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
        1 0 0 0
    }
} [
    { 123 } return-addresses set
    { T{ gc-map { scrub-d { 0 1 1 1 0 } } } } gc-maps set
    serialize-gc-maps
] unit-test

! gc-info + ret-addr + 9bits (5+2+2) = 28 + 4 + 2 = 34
{ 34 } [
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

! gc-info + ret-addr + 3 base-pointers + 9bits = 28 + 4 + 12 + 2 = 46
{ 46 } [
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
