USING: compiler.cfg.linear-scan.resolve tools.test kernel namespaces
accessors
compiler.cfg
compiler.cfg.instructions cpu.architecture make sequences
compiler.cfg.linear-scan.allocation.state ;
IN: compiler.cfg.linear-scan.resolve.tests

[
    {
        {
            T{ location f T{ spill-slot f 0 } int-rep int-regs }
            T{ location f 1 int-rep int-regs }
        }
    }
] [
    [
        0 <spill-slot> 1 int-rep add-mapping
    ] { } make
] unit-test

[
    {
        T{ _reload { dst 1 } { rep int-rep } { src T{ spill-slot f 0 } } }
    }
] [
    [
        T{ location f T{ spill-slot f 0 } int-rep int-regs }
        T{ location f 1 int-rep int-regs }
        >insn
    ] { } make
] unit-test

[
    {
        T{ _spill { src 1 } { rep int-rep } { dst T{ spill-slot f 0 } } }
    }
] [
    [
        T{ location f 1 int-rep int-regs }
        T{ location f T{ spill-slot f 0 } int-rep int-regs }
        >insn
    ] { } make
] unit-test

[
    {
        T{ ##copy { src 1 } { dst 2 } { rep int-rep } }
    }
] [
    [
        T{ location f 1 int-rep int-regs }
        T{ location f 2 int-rep int-regs }
        >insn
    ] { } make
] unit-test

[
    {
        T{ ##copy { src 1 } { dst 2 } { rep int-rep } }
        T{ ##branch }
    }
] [
    { { T{ location f 1 int-rep int-regs } T{ location f 2 int-rep int-regs } } }
    mapping-instructions
] unit-test

[
    {
        T{ _spill { src 0 } { rep int-rep } { dst T{ spill-slot f 0 } } }
        T{ _reload { dst 0 } { rep tagged-rep } { src T{ spill-slot f 1 } } }
        T{ ##branch }
    }
] [
    {
        { T{ location f T{ spill-slot f 1 } tagged-rep int-regs } T{ location f 0 tagged-rep int-regs } }
        { T{ location f 0 int-rep int-regs } T{ location f T{ spill-slot f 0 } int-rep int-regs } }
    }
    mapping-instructions
] unit-test

[
    {
        T{ _spill { src 0 } { rep int-rep } { dst T{ spill-slot f 1 } } }
        T{ _reload { dst 0 } { rep tagged-rep } { src T{ spill-slot f 0 } } }
        T{ ##branch }
    }
] [
    {
        { T{ location f T{ spill-slot f 0 } tagged-rep int-regs } T{ location f 0 tagged-rep int-regs } }
        { T{ location f 0 int-rep int-regs } T{ location f T{ spill-slot f 1 } int-rep int-regs } }
    }
    mapping-instructions
] unit-test

[
    {
        T{ _spill { src 0 } { rep int-rep } { dst T{ spill-slot f 1 } } }
        T{ _reload { dst 0 } { rep tagged-rep } { src T{ spill-slot f 0 } } }
        T{ ##branch }
    }
] [
    {
        { T{ location f 0 int-rep int-regs } T{ location f T{ spill-slot f 1 } int-rep int-regs } }
        { T{ location f T{ spill-slot f 0 } tagged-rep int-regs } T{ location f 0 tagged-rep int-regs } }
    }
    mapping-instructions
] unit-test

cfg new 8 >>spill-area-size cfg set
H{ } clone spill-temps set

[ t ] [
    {
        { T{ location f 0 int-rep int-regs } T{ location f 1 int-rep int-regs } }
        { T{ location f 1 int-rep int-regs } T{ location f 0 int-rep int-regs } }
    }
    mapping-instructions {
        {
            T{ _spill { src 0 } { rep int-rep } { dst T{ spill-slot f 8 } } }
            T{ ##copy { dst 0 } { src 1 } { rep int-rep } }
            T{ _reload { dst 1 } { rep int-rep } { src T{ spill-slot f 8 } } }
            T{ ##branch }
        }
        {
            T{ _spill { src 1 } { rep int-rep } { dst T{ spill-slot f 8 } } }
            T{ ##copy { dst 1 } { src 0 } { rep int-rep } }
            T{ _reload { dst 0 } { rep int-rep } { src T{ spill-slot f 8 } } }
            T{ ##branch }
        }
    } member?
] unit-test
