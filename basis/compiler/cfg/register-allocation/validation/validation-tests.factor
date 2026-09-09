USING: accessors arrays assocs compiler.cfg
compiler.cfg.linear-scan.allocation.state compiler.cfg.register-allocation
compiler.cfg.register-allocation.validation compiler.cfg.register-allocation.verifier
kernel locals math namespaces sequences tools.test ;
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
