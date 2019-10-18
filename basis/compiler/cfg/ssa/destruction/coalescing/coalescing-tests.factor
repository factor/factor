USING: assocs compiler.cfg.def-use compiler.cfg.instructions
compiler.cfg.registers compiler.cfg.ssa.destruction.coalescing
compiler.cfg.ssa.destruction.leaders
compiler.cfg.ssa.interference compiler.cfg.utilities
compiler.utilities cpu.architecture grouping kernel make
namespaces random sequences tools.test ;
IN: compiler.cfg.ssa.destruction.coalescing.tests

! eliminatable-copy?
{ { f t t f } } [
    H{
        { 45 double-2-rep }
        { 46 double-rep }
        { 47 double-rep }
        { 100 double-rep }
        { 20 tagged-rep }
        { 30 int-rep }
    } representations set
    { { 45 46 } { 47 100 } { 20 30 } { 30 100 } }
    [ first2 eliminatable-copy? ] map
] unit-test

! initial-class-elements
{
    H{
        {
            77
            { T{ vreg-info { vreg 77 } { value 77 } { bb "bb2" } } }
        }
        {
            123
            {
                T{ vreg-info
                   { vreg 123 }
                   { value 123 }
                   { bb "bb1" }
                }
            }
        }
    }
} [
    H{ { 123 "bb1" } { 77 "bb2" } } defs set
    initial-class-elements
] unit-test

! initial-leaders
{
    H{ { 65 65 } { 99 99 } { 62 62 } { 303 303 } }
} [
    {
        T{ ##load-vector
           { dst 62 }
           { val B{ 0 0 0 0 0 0 0 64 0 0 0 0 0 0 52 64 } }
           { rep double-2-rep }
        }
        T{ ##add-vector
           { dst 65 }
           { src1 62 }
           { src2 63 }
           { rep double-2-rep }
        }
        T{ ##allot
           { dst 99 }
           { size 24 }
           { temp 303 }
        }
    } initial-leaders
] unit-test

! init-coalescing
{
    H{ { 118 118 } }
} [
    { T{ ##phi { dst 118 } { inputs H{ { 4 120 } { 2 119 } } } } }
    [ insns>cfg compute-defs ] [ init-coalescing ] bi
    leader-map get
] unit-test

! try-eliminate-copy
{ } [
    10 10 f try-eliminate-copy
] unit-test

! coalesce-later
{ V{ { 2 1 } } } [
    [
        T{ ##copy { src 1 } { dst 2 } { rep int-rep } } coalesce-later
    ] V{ } make
] unit-test

{ V{ { 3 4 } { 7 8 } } } [
    [
        T{ ##parallel-copy { values V{ { 3 4 } { 7 8 } } } } coalesce-later
    ] V{ } make
] unit-test

! All this work to make the 'values' order non-deterministic.
: make-phi-inputs ( -- assoc )
    H{ } clone [
        { 2287 2288 } [
            10 <iota> 1 sample first rot set-at
        ] with each
    ] keep ;

{ t } [
    10 [
        { 2286 2287 2288 } unique leader-map set
        2286 make-phi-inputs ##phi new-insn
        coalesce-now
        2286 leader
    ] replicate all-equal?
] unit-test
