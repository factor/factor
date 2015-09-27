USING: alien.c-types compiler.cfg.builder.alien compiler.cfg.instructions
compiler.cfg.registers compiler.cfg.stacks.local compiler.test
cpu.architecture kernel make namespaces system tools.test ;
IN: compiler.cfg.builder.alien.tests

! unboxing ints is only needed on 32bit archs
cpu x86.32?
{
    { 2 4 }
    { { int-rep f f } { int-rep f f } }
    V{
        T{ ##unbox-any-c-ptr { dst 2 } { src 1 } }
        T{ ##unbox
           { dst 4 }
           { src 3 }
           { unboxer "to_fixnum" }
           { rep int-rep }
        }
    }
}
{
    { 2 3 }
    { { int-rep f f } { int-rep f f } }
    V{ T{ ##unbox-any-c-ptr { dst 2 } { src 1 } } }
} ? [
    [ { c-string int } unbox-parameters ] V{ } make
] cfg-unit-test
