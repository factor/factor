USING: accessors assocs compiler.errors debugger io kernel namespaces prettyprint sequences system tools.test ;
f restartable-tests? set-global
USING: compiler.cfg.checker compiler.cfg.linear-scan.allocation.state
compiler.cfg.register-allocation compiler.cfg.register-allocation.greedy
compiler.cfg.register-allocation.backtracking compiler.cfg.register-allocation.chordal
compiler.cfg.value-numbering ;
check-ssa? on
check-allocation? on
global-value-numbering? on
{ linear-scan-allocator greedy-allocator backtracking-allocator chordal-allocator } [
    dup . flush register-allocator set
    "compiler.cfg.multiply-negate" test
    { "resource:basis/compiler/tests/alien.factor"
      "resource:basis/compiler/tests/alien-large-return.factor"
      "resource:basis/compiler/tests/alien-small-floats.factor"
      "resource:basis/compiler/tests/alien-arm64-abi.factor"
      "resource:basis/compiler/tests/alien-varargs.factor"
      "resource:basis/compiler/tests/alien-varargs-outgoing.factor"
      "resource:basis/compiler/tests/alien-varargs-promotions.factor"
      "resource:basis/compiler/tests/alien-arm64-unions.factor" }
    [ dup print flush run-test-file ] each
] each

"TEST FAILURES " write test-failures get length .
"COMPILER ERRORS " write compiler-errors get assoc-size .
test-failures get [ error>> print-error ] each
compiler-errors get values [ print-error ] each flush
test-failures get empty? compiler-errors get assoc-empty? and 0 1 ? exit
