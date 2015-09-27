USING: alien.c-types compiler.cfg.builder.alien.boxing
compiler.cfg.instructions compiler.test cpu.architecture kernel make system
tools.test ;
IN: compiler.cfg.builder.alien.boxing.tests

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
