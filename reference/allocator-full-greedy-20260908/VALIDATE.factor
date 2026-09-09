USING: vocabs.loader tools.test namespaces sequences
compiler.cfg.register-allocation.greedy
compiler.cfg.linear-scan.allocation.state
compiler.cfg.register-allocation.verifier ;
"compiler.cfg.linear-scan.assignment" reload
"compiler.cfg.register-allocation.greedy" reload
t check-allocation? set
greedy-allocator register-allocator set
"compiler.cfg" test
:test-failures
test-failures get empty? [ 0 ] [ 1 ] if exit
