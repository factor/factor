USING: accessors assocs biassocs combinators compiler.cfg
compiler.cfg.instructions compiler.cfg.registers compiler.cfg.stacks
compiler.cfg.stacks.height compiler.cfg.stacks.local compiler.cfg.utilities
compiler.test cpu.architecture make namespaces kernel tools.test ;
QUALIFIED: sets
IN: compiler.cfg.stacks.local.tests

! loc>vreg
{ 1 } [
    D 0 loc>vreg
] cfg-unit-test

! stack-changes
{
    {
        T{ ##copy { dst 1 } { src 25 } { rep any-rep } }
        T{ ##copy { dst 2 } { src 26 } { rep any-rep } }
    }
} [
    { { D 0 25 } { R 0 26 } } stack-changes
] cfg-unit-test

! replace-loc
{ 80 } [
    80 D 77 replace-loc
    D 77 peek-loc
] cfg-unit-test

! end-local-analysis
{
    HS{ }
    { }
    HS{ }
} [
    "foo" [ "eh" , end-local-analysis ] V{ } make drop
    "foo" [ peek-sets ] [ replace-sets ] [ kill-sets ] tri [ get at ] 2tri@
] cfg-unit-test

{
    { D 3 }
} [
    "foo" [ 3 D 3 replace-loc "eh" , end-local-analysis ] V{ } make drop
    replace-sets get "foo" of
] unit-test

! remove-redundant-replaces
{
    H{ { T{ ds-loc { n 3 } } 7 } }
} [
    D 0 loc>vreg D 2 loc>vreg 2drop
    2 D 2 replace-loc 7 D 3 replace-loc
    replace-mapping get remove-redundant-replaces
] cfg-unit-test

! emit-changes
{
    V{ T{ ##copy { dst 1 } { src 3 } { rep any-rep } } "eh" }
} [
    3 D 0 replace-loc [
        "eh",
        replace-mapping get height-state get emit-changes
    ] V{ } make
] cfg-unit-test

! height-state
{
    { { 3 3 } { 0 0 } }
} [
    D 3 inc-stack height-state get
] cfg-unit-test

{
    { { 5 3 } { 0 0 } }
} [
    { { 2 0 } { 0 0 } } height-state set
    D 3 inc-stack height-state get
] cfg-unit-test

{
    { T{ ##inc { loc D 4 } } T{ ##inc { loc R -2 } } }
} [
    { { 0 4  } { 0 -2 } } height-state>insns
] unit-test

{ H{ { D -1 40 } } } [
    D 1 inc-stack 40 D 0 replace-loc replace-mapping get
] cfg-unit-test

{ 0 } [
    V{ } 0 insns>block basic-block set
    init-cfg-test
    compute-local-kill-set sets:cardinality
] unit-test

{ HS{ R -4 } } [
    H{ { 77 4 } } [ ds-heights set ] [ rs-heights set ] bi
    { { 8 0 } { 3 0 } } height-state set
    77 basic-block set
    compute-local-kill-set
] unit-test

{ D 2 } [
    { { 1 2 } { 3 4 } } D 3 translate-local-loc
] unit-test
