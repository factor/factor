USING: vocabs.loader tools.test namespaces sequences system ;
"compiler.cfg.register-allocation.chordal.spilling.residency" require
"compiler.cfg.register-allocation.chordal.spilling.residency" test
:test-failures test-failures get empty? [ 0 ] [ 1 ] if exit
