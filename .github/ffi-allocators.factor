USING: accessors assocs compiler.errors debugger io kernel namespaces prettyprint sequences system tools.test vocabs.hierarchy ;
f restartable-tests? set-global
USING: compiler.cfg.checker compiler.cfg.linear-scan.allocation.state
compiler.cfg.register-allocation compiler.cfg.register-allocation.greedy
compiler.cfg.register-allocation.backtracking compiler.cfg.register-allocation.chordal
compiler.cfg.value-numbering ;
check-ssa? on
check-allocation? on
global-value-numbering? on
"math.floats.env" [ load ] [ test ] bi
{ linear-scan-allocator greedy-allocator backtracking-allocator chordal-allocator } [
    dup . flush register-allocator set
    "compiler.cfg.multiply-negate" test
    { "resource:basis/compiler/tests/alien.factor"
      "resource:basis/compiler/tests/alien-large-return.factor"
      "resource:basis/compiler/tests/alien-linux-runtime.factor"
      "resource:basis/compiler/tests/alien-linux-regressions.factor"
      "resource:basis/compiler/tests/alien-small-floats.factor"
      "resource:basis/compiler/tests/alien-arm64-abi.factor" }
    [ dup print flush run-test-file ] each
    test-failures get empty? compiler-errors get assoc-empty? and
    [ :test-failures compiler-errors get values [ print-error ] each
      "Allocator FFI verification failed" throw ] unless
] each

"TEST FAILURES " write test-failures get length .
"COMPILER ERRORS " write compiler-errors get assoc-size .
test-failures get [ error>> print-error ] each
compiler-errors get values [ print-error ] each flush
test-failures get empty? compiler-errors get assoc-empty? and 0 1 ? exit
