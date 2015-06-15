USING: assocs compiler.cfg.def-use compiler.cfg.instructions
compiler.cfg.ssa.destruction.coalescing compiler.cfg.ssa.destruction.leaders
cpu.architecture grouping kernel make namespaces random sequences tools.test ;
QUALIFIED: sets
IN: compiler.cfg.ssa.destruction.coalescing.tests

! init-coalescing
{
    H{ { 123 123 } { 77 77 } }
} [
    H{ { 123 "bb1" } { 77 "bb2" } } defs set
    init-coalescing
    leader-map get
] unit-test

! try-eliminate-copy
{ } [
    10 10 f try-eliminate-copy
] unit-test

! coalesce-insn
{ V{ { 2 1 } } } [
    [
        T{ ##copy { src 1 } { dst 2 } { rep int-rep } } coalesce-insn
    ] V{ } make
] unit-test

{ V{ { 3 4 } { 7 8 } } } [
    [
        T{ ##parallel-copy { values V{ { 3 4 } { 7 8 } } } } coalesce-insn
    ] V{ } make
] unit-test

! All this work to make the 'values' order non-deterministic.
: make-phi-inputs ( -- assoc )
    H{ } clone [
        { 2287 2288 } [
            10 iota 1 sample first rot set-at
        ] with each
    ] keep ;

{ t } [
    10 [
        { 2286 2287 2288 } sets:unique leader-map set
        2286 make-phi-inputs ##phi new-insn
        coalesce-insn
        2286 leader
    ] replicate all-equal?
] unit-test
