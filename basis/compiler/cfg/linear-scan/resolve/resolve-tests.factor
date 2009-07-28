IN: compiler.cfg.linear-scan.resolve.tests
USING: compiler.cfg.linear-scan.resolve tools.test kernel namespaces
compiler.cfg.instructions cpu.architecture make
compiler.cfg.linear-scan.allocation.state ;

[
    {
        { { T{ spill-slot f 0 } int-regs } { 1 int-regs } }
    }
] [
    [
        0 <spill-slot> 1 int-regs add-mapping
    ] { } make
] unit-test

[
    {
        T{ _reload { dst 1 } { class int-regs } { n 0 } }
    }
] [
    [
        { T{ spill-slot f 0 } int-regs } { 1 int-regs } >insn
    ] { } make
] unit-test

[
    {
        T{ _spill { src 1 } { class int-regs } { n 0 } }
    }
] [
    [
        { 1 int-regs } { T{ spill-slot f 0 } int-regs } >insn
    ] { } make
] unit-test

[
    {
        T{ _copy { src 1 } { dst 2 } { class int-regs } }
    }
] [
    [
        { 1 int-regs } { 2 int-regs } >insn
    ] { } make
] unit-test

H{ { int-regs 10 } { float-regs 20 } } clone spill-counts set
H{ } clone spill-temps set

[
    {
        T{ _spill { src 0 } { class int-regs } { n 10 } }
        T{ _copy { dst 0 } { src 1 } { class int-regs } }
        T{ _reload { dst 1 } { class int-regs } { n 10 } }
    }
] [
    { { { 0 int-regs } { 1 int-regs } } { { 1 int-regs } { 0 int-regs } } }
    mapping-instructions
] unit-test