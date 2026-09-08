USE: vocabs.refresh
<< "cpu.architecture" reload "cpu" refresh "compiler" refresh >>
USING: accessors command-line compiler.cfg.checker compiler.cfg.value-numbering compiler.cfg.metrics
compiler.cfg.register-allocation
compiler.cfg.register-allocation.backtracking
compiler.cfg.register-allocation.chordal
compiler.cfg.register-allocation.greedy
compiler.cfg.linear-scan.allocation.state debugger io kernel namespaces
prettyprint sequences system tools.test tools.test.private words ;
f restartable-tests? set-global
check-allocation? on
check-ssa? on
"global" command-line get member? global-value-numbering? set
command-line get first {
    { "linear-scan" [ linear-scan-allocator ] }
    { "greedy" [ greedy-allocator ] }
    { "backtracking" [ backtracking-allocator ] }
    { "chordal" [ chordal-allocator ] }
} case register-allocator set
"compiler" test
"TEST-FAILURES " write test-failures get length .
test-failures get [ error>> print-error ] each
test-failures get empty? 0 1 ? exit
