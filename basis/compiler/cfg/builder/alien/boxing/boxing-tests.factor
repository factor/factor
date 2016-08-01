USING: alien.c-types classes.struct compiler.cfg.builder.alien.boxing
compiler.cfg.instructions compiler.test cpu.architecture kernel make
system tools.test ;
IN: compiler.cfg.builder.alien.boxing.tests

STRUCT: some-struct
    { f1 int }
    { f2 int }
    { f3 int }
    { f4 int } ;

! flatten-c-type
{
    { { int-rep f f } }
} [
    int base-type flatten-c-type
] unit-test

cpu x86.64? [
    {
        { { int-rep f f } { int-rep f f } }
    } [
        some-struct base-type base-type flatten-c-type
    ] unit-test
] when

! unbox
{
    { 20 }
    { { int-rep f f } }
} [
    20 int base-type unbox
] unit-test

cpu x86.64? [
    {
        { 2 3 }
        { { int-rep f f } { int-rep f f } }
        V{
            T{ ##unbox-any-c-ptr { dst 1 } { src 20 } }
            T{ ##load-memory-imm
               { dst 2 }
               { base 1 }
               { offset 0 }
               { rep int-rep }
             }
            T{ ##load-memory-imm
               { dst 3 }
               { base 1 }
               { offset 8 }
               { rep int-rep }
             }
        }
    } [
        [ 20 some-struct base-type unbox ] V{ } make
    ] cfg-unit-test
] when

! unbox-parameter
{
    { 1 }
    { { int-rep f f } }
    V{ T{ ##unbox-any-c-ptr { dst 1 } { src 77 } } }
} [
    [ 77 c-string base-type unbox-parameter ] V{ } make
] cfg-unit-test

! unboxing is only needed on 32bit archs
cpu x86.32?
{
    { 1 }
    { { int-rep f f } }
    V{
        T{ ##unbox
           { dst 1 }
           { src 77 }
           { unboxer "to_fixnum" }
           { rep int-rep }
        }
    }
}
{ { 77 } { { int-rep f f } } V{ } } ? [
    [ 77 int base-type unbox-parameter ] V{ } make
] cfg-unit-test
