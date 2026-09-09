USING: accessors arrays assocs compiler.cfg
compiler.cfg.linear-scan.allocation.state compiler.cfg.register-allocation
compiler.cfg.register-allocation.validation compiler.cfg.register-allocation.verifier
compiler.cfg.register-allocation.rematerialization compiler.test cpu.architecture
kernel kernel.private locals math math.vectors.simd namespaces sequences tools.test ;
IN: compiler.cfg.register-allocation.validation.tests

{ } [
    H{ { "algorithm" "test-policy" } { "fallback-count" 0 }
        { "region-splits" 2 } { "recolor-commits" 1 } }
    "test-policy" { "region-splits" "recolor-commits" } check-allocation-evidence
] unit-test

[
    H{ { "algorithm" "linear-scan" } { "fallback-count" 0 } }
    "test-policy" { } check-allocation-evidence
] [ invalid-allocation-evidence? ] must-fail-with

[
    H{ { "algorithm" "test-policy" } { "fallback-count" 1 } }
    "test-policy" { } check-allocation-evidence
] [ invalid-allocation-evidence? ] must-fail-with

[
    H{ { "algorithm" "test-policy" } { "fallback-count" 0 }
        { "region-splits" 0 } }
    "test-policy" { "region-splits" } check-allocation-evidence
] [ invalid-allocation-evidence? ] must-fail-with

[
    H{ { "algorithm" "test-policy" } { "fallback-count" 0 } }
    "test-policy" { "recolor-commits" } check-allocation-evidence
] [ invalid-allocation-evidence? ] must-fail-with

! Native results are checked against scalar formulae, independently of the
! allocator's intervals, phi maps and generated transport instructions.
{ t } [ [
    3 <iota> [| seed |
        6 seed <validation-diamond> :> graph
        graph 4 2 validation-register-bank :> bank
        linear-scan-allocator bank [ linear-scan-allocation-with-registers ]
        constrained-allocator boa graph swap compile-validation-cfg :> word
        { -9 -1 0 1 9 } [| input |
            input word execute( x -- y ) input 6 seed validation-diamond-result =
        ] all?
    ] all?
] with-scope ] unit-test

{ t } [ [
    3 <iota> [| seed |
        { f t } [| collect? |
            seed collect? <validation-cycle> :> graph
            graph 4 2 validation-register-bank :> bank
            linear-scan-allocator bank [ linear-scan-allocation-with-registers ]
            constrained-allocator boa graph swap compile-validation-cfg :> word
            { 0 1 2 3 8 } [| iterations |
                iterations word execute( x -- y )
                iterations seed validation-cycle-result =
            ] all?
        ] all?
    ] all?
] with-scope ] unit-test

! A kernel may not silently widen its reduced bank. This independent final
! operand audit rejects that even if the kernel checked its own wider bank.
[
    1 int-rep H{ { int-regs { 0 } } } check-validation-location
] [ outside-validation-register-bank? ] must-fail-with

! Missing classes, duplicate registers, and reserved-register substitutes
! are rejected before invoking an allocator kernel.
[
    3 0 <validation-diamond> H{ } check-validation-register-bank
] [ invalid-validation-register-bank? ] must-fail-with

[
    [ [let
        6 0 <validation-diamond> :> graph
        graph 3 2 validation-register-bank :> reduced
        linear-scan-allocator reduced [
            ! Deliberately corrupt the constraint handoff by discarding it.
            drop dup 999 999 validation-register-bank
            linear-scan-allocation-with-registers
        ] constrained-allocator boa
        graph swap compile-validation-cfg drop
    ] ] with-scope
] [ outside-validation-register-bank? ] must-fail-with


{ t } [ [
    0 f <validation-cycle> 8 4 validation-register-bank
    [ linear-scan-allocator ] dip [ linear-scan-allocation-with-registers ]
    constrained-allocator boa register-allocator set
    t check-allocation? set
    { 0.0 0.5 -0.5 } [| x |
        double-2{ 2.0 3.0 } double-2{ 5.0 7.0 } x
        [ { double-2 double-2 float } declare
          validation-vector-program ] compile-call >array
        2.0 5.0 x validation-vector-lane
        3.0 7.0 x validation-vector-lane 2array =
    ] all?
] with-scope ] unit-test


! These are moving heap pointers, not just fixnum bits passing a GC clobber.
! Both phi predecessors and rematerialization settings execute with a bank
! small enough to force traffic around the two scratch registers.
{ t } [ [
    { f t } [| rematerialize? |
        rematerialize? rematerialize-constants? set
        <validation-moving-tagged-phi> :> graph
        graph 4 2 validation-register-bank :> bank
        linear-scan-allocator bank [ linear-scan-allocation-with-registers ]
        constrained-allocator boa graph swap compile-validation-cfg
        check-validation-moving-phi
    ] all?
] with-scope ] unit-test
