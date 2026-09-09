USING: accessors arrays compiler.cfg compiler.cfg.register-allocation
compiler.cfg.register-allocation.backtracking
compiler.cfg.register-allocation.greedy
compiler.cfg.register-allocation.validation compiler.cfg.register-allocation.verifier
io kernel locals namespaces sequences tools.test ;
IN: allocator-full.integration.validation

:: validate-reduced-diamonds ( allocator kernel -- )
    { 3 6 12 } [| width |
        { 0 1 7 } [| seed |
            { 3 4 6 } [| count |
                width seed <validation-diamond> :> graph
                graph count 2 validation-register-bank :> bank
                graph allocator bank kernel constrained-allocator boa
                compile-validation-cfg :> word
                { -101 -9 -1 0 1 9 101 } [| input |
                    input word execute( x -- y )
                    input width seed validation-diamond-result assert=
                ] each
            ] each
        ] each
    ] each ;

:: validate-reduced-cycles ( allocator kernel -- )
    { 0 1 7 } [| seed |
        { f t } [| collect? |
            seed collect? <validation-cycle> :> graph
            graph 4 2 validation-register-bank :> bank
            graph allocator bank kernel constrained-allocator boa
            compile-validation-cfg :> word
            { 0 1 2 3 8 19 } [| iterations |
                iterations word execute( x -- y )
                iterations seed validation-cycle-result assert=
            ] each
        ] each
    ] each ;

:: validate-reduced-corpus ( allocator kernel -- )
    allocator kernel validate-reduced-diamonds
    allocator kernel validate-reduced-cycles
    "33 reduced-bank CFGs / 225 independent native answers passed" print ;
