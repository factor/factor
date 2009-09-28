USING: compiler.cfg.linear-scan.resolve tools.test kernel namespaces
accessors
compiler.cfg
compiler.cfg.instructions cpu.architecture make sequences
compiler.cfg.linear-scan.allocation.state ;
IN: compiler.cfg.linear-scan.resolve.tests

[
    {
        { { T{ spill-slot f 0 } int-rep } { 1 int-rep } }
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
        { T{ spill-slot f 0 } int-rep } { 1 int-rep } >insn
    ] { } make
] unit-test

[
    {
        T{ _spill { src 1 } { rep int-rep } { dst T{ spill-slot f 0 } } }
    }
] [
    [
        { 1 int-rep } { T{ spill-slot f 0 } int-rep } >insn
    ] { } make
] unit-test

[
    {
        T{ ##copy { src 1 } { dst 2 } { rep int-rep } }
    }
] [
    [
        { 1 int-rep } { 2 int-rep } >insn
    ] { } make
] unit-test

cfg new 8 >>spill-area-size cfg set
H{ } clone spill-temps set

[
    t
] [
    { { { 0 int-rep } { 1 int-rep } } { { 1 int-rep } { 0 int-rep } } }
    mapping-instructions {
        {
            T{ _spill { src 0 } { rep int-rep } { dst T{ spill-slot f 8 } } }
            T{ ##copy { dst 0 } { src 1 } { rep int-rep } }
            T{ _reload { dst 1 } { rep int-rep } { src T{ spill-slot f 8 } } }
        }
        {
            T{ _spill { src 1 } { rep int-rep } { dst T{ spill-slot f 8 } } }
            T{ ##copy { dst 1 } { src 0 } { rep int-rep } }
            T{ _reload { dst 0 } { rep int-rep } { src T{ spill-slot f 8 } } }
        }
    } member?
] unit-test
