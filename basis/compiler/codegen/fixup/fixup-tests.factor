USING: namespaces byte-arrays make compiler.codegen.fixup
bit-arrays accessors classes.struct tools.test kernel math
sequences alien.c-types specialized-arrays boxes ;
SPECIALIZED-ARRAY: uint
IN: compiler.codegen.fixup.tests

STRUCT: gc-info
{ scrub-d-count uint }
{ scrub-r-count uint }
{ gc-root-count uint }
{ return-address-count uint } ;

[ ] [
    [
        init-fixup

        50 <byte-array> %

        { { } { } { } } set-next-gc-map
        gc-map-here

        50 <byte-array> %

        { { 0 4 } { 1 } { 1 3 } } set-next-gc-map
        gc-map-here

        emit-gc-info
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

        ! Return addresses - 4 bytes
        uint-array{ 100 } underlying>> %

        ! GC info footer - 16 bytes
        S{ gc-info
            { scrub-d-count 5 }
            { scrub-r-count 2 }
            { gc-root-count 4 }
            { return-address-count 1 }
        } (underlying)>> %
    ] B{ } make
    "expect" set
] unit-test

[ ] [ "result" get length "expect" get length assert= ] unit-test
[ ] [ "result" get "expect" get assert= ] unit-test
