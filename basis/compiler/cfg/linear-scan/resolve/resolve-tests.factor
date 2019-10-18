USING: accessors compiler.cfg compiler.cfg.instructions
compiler.cfg.linear-scan.resolve compiler.cfg.utilities
cpu.architecture kernel make namespaces sequences tools.test ;
IN: compiler.cfg.linear-scan.resolve.tests

{
    {
        {
            T{ location f T{ spill-slot f 0 } int-rep int-regs }
            T{ location f 1 int-rep int-regs }
        }
    }
} [
    [
        0 <spill-slot> 1 int-rep add-mapping
    ] { } make
] unit-test

{
    {
        T{ ##reload { dst 1 } { rep int-rep } { src T{ spill-slot f 0 } } }
    }
} [
    [
        T{ location f T{ spill-slot f 0 } int-rep int-regs }
        T{ location f 1 int-rep int-regs }
        >insn
    ] { } make
] unit-test

{
    {
        T{ ##spill { src 1 } { rep int-rep } { dst T{ spill-slot f 0 } } }
    }
} [
    [
        T{ location f 1 int-rep int-regs }
        T{ location f T{ spill-slot f 0 } int-rep int-regs }
        >insn
    ] { } make
] unit-test

{
    {
        T{ ##copy { src 1 } { dst 2 } { rep int-rep } }
    }
} [
    [
        T{ location f 1 int-rep int-regs }
        T{ location f 2 int-rep int-regs }
        >insn
    ] { } make
] unit-test

{
    {
        T{ ##copy { src 1 } { dst 2 } { rep int-rep } }
        T{ ##branch }
    }
} [
    { { T{ location f 1 int-rep int-regs } T{ location f 2 int-rep int-regs } } }
    mapping-instructions
] unit-test

{
    {
        T{ ##spill { src 0 } { rep int-rep } { dst T{ spill-slot f 0 } } }
        T{ ##reload { dst 0 } { rep tagged-rep } { src T{ spill-slot f 1 } } }
        T{ ##branch }
    }
} [
    {
        { T{ location f T{ spill-slot f 1 } tagged-rep int-regs } T{ location f 0 tagged-rep int-regs } }
        { T{ location f 0 int-rep int-regs } T{ location f T{ spill-slot f 0 } int-rep int-regs } }
    }
    mapping-instructions
] unit-test

{
    {
        T{ ##spill { src 0 } { rep int-rep } { dst T{ spill-slot f 1 } } }
        T{ ##reload { dst 0 } { rep tagged-rep } { src T{ spill-slot f 0 } } }
        T{ ##branch }
    }
} [
    {
        { T{ location f T{ spill-slot f 0 } tagged-rep int-regs } T{ location f 0 tagged-rep int-regs } }
        { T{ location f 0 int-rep int-regs } T{ location f T{ spill-slot f 1 } int-rep int-regs } }
    }
    mapping-instructions
] unit-test

{
    {
        T{ ##spill { src 0 } { rep int-rep } { dst T{ spill-slot f 1 } } }
        T{ ##reload { dst 0 } { rep tagged-rep } { src T{ spill-slot f 0 } } }
        T{ ##branch }
    }
} [
    {
        { T{ location f 0 int-rep int-regs } T{ location f T{ spill-slot f 1 } int-rep int-regs } }
        { T{ location f T{ spill-slot f 0 } tagged-rep int-regs } T{ location f 0 tagged-rep int-regs } }
    }
    mapping-instructions
] unit-test

{ } insns>cfg [ stack-frame>> 8 >>spill-area-size drop ] [ cfg set ] bi
init-resolve

{ t } [
    {
        { T{ location f 0 int-rep int-regs } T{ location f 1 int-rep int-regs } }
        { T{ location f 1 int-rep int-regs } T{ location f 0 int-rep int-regs } }
    }
    mapping-instructions {
        {
            T{ ##spill { src 0 } { rep int-rep } { dst T{ spill-slot f 8 } } }
            T{ ##copy { dst 0 } { src 1 } { rep int-rep } }
            T{ ##reload { dst 1 } { rep int-rep } { src T{ spill-slot f 8 } } }
            T{ ##branch }
        }
        {
            T{ ##spill { src 1 } { rep int-rep } { dst T{ spill-slot f 8 } } }
            T{ ##copy { dst 1 } { src 0 } { rep int-rep } }
            T{ ##reload { dst 0 } { rep int-rep } { src T{ spill-slot f 8 } } }
            T{ ##branch }
        }
    } member?
] unit-test
