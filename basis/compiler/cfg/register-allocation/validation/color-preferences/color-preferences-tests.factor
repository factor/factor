USING: arrays assocs compiler.cfg.register-allocation.chordal
compiler.cfg.register-allocation.validation.color-preferences
compiler.cfg.registers cpu.architecture kernel locals math math.bitwise
namespaces sequences tools.test ;
IN: compiler.cfg.register-allocation.validation.color-preferences.tests

! All nonempty free subsets, sparse/missing scores, rational weights, and
! nonadjacent ties. Scores outside the available bank must be irrelevant.
{ t } [
    15 <iota> [| mask |
        4 <iota> [ 1 swap shift mask 1 + bitand 0 > ] filter :> free
        16 <iota> [| seed |
            4 <iota> [| color | color color seed + 4 mod 1/8 * ] H{ } map>assoc :> preferences
            H{ { 0 1/8 } { 2 1/8 } { 99 1000000 } } :> shared
            free preferences shared preferred-free-color
            free preferences shared sorted-preference-color =
        ] all?
    ] all?
] unit-test

{ 0 1 } [
    { 0 1 3 } H{ } H{ } preferred-free-color
    { 0 1 3 } H{ { 1 4 } { 3 4 } } H{ } preferred-free-color
] unit-test

! Complete maps (or explicit exhaustion) on every four-vertex graph;
! affinities can conflict with interference. Both traversal directions and
! capacities 1..4 expose downstream effects of a single wrong tie choice.
{ t } [
    H{ { 0 int-rep } { 1 int-rep } { 2 int-rep } { 3 int-rep } }
    representations [
        64 <iota> [| mask |
            mask preference-test-graph :> graph
            { 0 1 7 21 42 63 } [| seed |
                seed preference-test-affinities :> affinities
                { { 0 1 2 3 } { 3 2 1 0 } } [| order |
                    4 <iota> [| capacity |
                        graph order affinities capacity 1 + compare-preference-colorings
                    ] all?
                ] all?
            ] all?
        ] all?
    ] with-variable
] unit-test
