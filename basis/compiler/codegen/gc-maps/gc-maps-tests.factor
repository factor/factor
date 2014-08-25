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

[ ] [
    [
        init-relocation
        init-gc-maps

        50 <byte-array> %

        T{ gc-map f B{ } B{ } V{ } } gc-map-here

        50 <byte-array> %

        T{ gc-map f B{ 0 1 1 1 0 } B{ 1 0 } V{ 1 3 } V{ { 2 4 } } } gc-map-here

        emit-gc-maps
    ] B{ } make
    "result" set
] unit-test

[ 0 ] [ "result" get length 16 mod ] unit-test

[ ] [
    [
        100 <byte-array> %

        ! The below data is 22 bytes -- 6 bytes padding needed to
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
        S{ gc-info
            { scrub-d-count 5 }
            { scrub-r-count 2 }
            { gc-root-count 4 }
            { derived-root-count 3 }
            { return-address-count 1 }
        } (underlying)>> %
    ] B{ } make
    "expect" set
] unit-test

[ ] [ "result" get length "expect" get length assert= ] unit-test
[ ] [ "result" get "expect" get assert= ] unit-test
