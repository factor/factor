USING: assocs compiler.errors compiler.units debugger io kernel namespaces sequences
 system tools.test vocabs.loader ;
f restartable-tests? set-global
[
    { "compiler.cfg.intrinsics.simd" "math.vectors.simd.intrinsics" "math.vectors.simd" } [ dup print flush reload ] each
] with-compilation-unit
"math.vectors.simd.intrinsics" test
test-failures get empty? compiler-errors get assoc-empty? and
[ "SIMD integration tests passed" print 0 ]
[ :test-failures compiler-errors get values [ print-error ] each 1 ] if flush exit
