USING: accessors compiler.cfg.register-allocation.verifier
compiler.cfg.register-allocation.verifier.tests io kernel locals sequences vocabs.loader ;
"/tmp/allocator-verifier-before-call.factor" run-file
[let
    callback-pointer-fixture :> ( graph snapshot )
    graph entry>> successors>> first successors>> first
    [ rest ] change-instructions drop
    graph snapshot check-value-flow
]
[let
    callback-pointer-fixture :> ( graph snapshot )
    graph entry>> successors>> first successors>> first
    [ 0 0 flow-spill prefix ] change-instructions drop
    graph snapshot check-value-flow
]
"OLD-CHECKER ACCEPTED BOTH CORRUPTIONS" print
