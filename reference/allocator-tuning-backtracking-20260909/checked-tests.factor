! Run in a fresh process after all integration commits have landed.
USE: vocabs.refresh
<< refresh-all >>
USING: accessors assocs combinators command-line compiler.cfg.checker
compiler.cfg.linear-scan.allocation.state compiler.cfg.register-allocation
compiler.cfg.register-allocation.backtracking
compiler.cfg.register-allocation.chordal compiler.cfg.register-allocation.greedy
compiler.cfg.register-allocation.rematerialization
compiler.cfg.register-allocation.spill-sites
compiler.cfg.register-allocation.verifier compiler.cfg.value-numbering
debugger io kernel namespaces prettyprint sequences system tools.test
tools.test.private words ;
IN: allocator-speed-validation

f restartable-tests? set-global
f silent-tests? set-global
t check-allocation? set-global
t check-ssa? set-global
f global-value-numbering? set-global
command-line get second "on" = rematerialize-constants? set-global
command-line get third "on" = backtracking-loop-spills? set-global
command-line get first {
    { "linear-scan" [ linear-scan-allocator ] }
    { "greedy" [ greedy-allocator ] }
    { "backtracking" [ backtracking-allocator ] }
    { "chordal" [ chordal-allocator ] }
} case register-allocator set-global

value-flow-verifier-enabled? t assert=
rematerialize-constants? get [
    rematerialization-observer get >boolean t assert=
] when
"SPEED compiler-suite allocator=" write current-register-allocator name>> write
" rematerialization=" write rematerialize-constants? get .
"SPEED loop-spills=" write backtracking-loop-spills? get .
"SPEED checks=ssa,intervals,final-value-flow gvn=off" print flush

"compiler.cfg.register-allocation.backtracking" test

test-failures get [ error>> error. ] each
"TEST-FAILURES " write test-failures get length .
test-failures get .
test-failures get empty? [
    value-flow-verifier-enabled? t assert=
    "SPEED compiler-suite=passed" print flush
    0
] [ 1 ] if exit
