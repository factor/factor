USING: accessors assocs biassocs combinators compiler.cfg
compiler.cfg.instructions compiler.cfg.registers compiler.cfg.stacks
compiler.cfg.stacks.height compiler.cfg.stacks.local compiler.cfg.stacks.tests
compiler.cfg.utilities cpu.architecture namespaces kernel tools.test ;
IN: compiler.cfg.stacks.local.tests

{
    { { 3 3 } { 0 0 } }
} [
    test-init
    D 3 inc-stack height-state get
] unit-test

{
    { { 5 3 } { 0 0 } }
} [
    { { 2 0 } { 0 0 } } height-state set
    D 3 inc-stack height-state get
] unit-test

{
    { T{ ##inc { loc D 4 } } T{ ##inc { loc R -2 } } }
} [
    { { 0 4  } { 0 -2 } } height-state>insns
] unit-test

{ 30 } [
    29 vreg-counter set-global <bihash> locs>vregs set D 0 loc>vreg
] unit-test

{
    {
        T{ ##copy { dst 1 } { src 25 } { rep any-rep } }
        T{ ##copy { dst 2 } { src 26 } { rep any-rep } }
    }
} [
    0 vreg-counter set-global <bihash> locs>vregs set
    { { D 0 25 } { R 0 26 } } stack-changes
] unit-test

{ 80 } [
    test-init
    80 D 77 replace-loc
    D 77 peek-loc
] unit-test

{ H{ { D -1 40 } } } [
    test-init
    D 1 inc-stack 40 D 0 replace-loc
    replace-mapping get
] unit-test

{ 0 } [
    V{ } 0 insns>block basic-block set
    begin-stack-analysis begin-local-analysis
    compute-local-kill-set assoc-size
] unit-test

{ H{ { R -4 R -4 } } } [
    H{ { 77 4 } } [ ds-heights set ] [ rs-heights set ] bi
    { { 8 0 } { 3 0 } } height-state set
    77 basic-block set
    compute-local-kill-set
] unit-test

{ D 2 } [
    { { 1 2 } { 3 4 } } D 3 translate-local-loc
] unit-test
