USING: assocs compiler.errors debugger io kernel namespaces parser
sequences system tools.test ;
f restartable-tests? set-global
"resource:basis/math/vectors/simd/intrinsics/intrinsics-tests.factor" run-test-file
:test-failures compiler-errors get values [ print-error ] each
test-failures get empty? compiler-errors get assoc-empty? and
[ "ARM64 SIMD intrinsics passed" print 0 ] [ 1 ] if flush exit
