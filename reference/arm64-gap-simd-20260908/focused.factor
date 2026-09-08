USING: accessors assocs compiler.errors debugger io kernel namespaces
prettyprint sequences system tools.test tools.test.private vocabs vocabs.loader ;
f restartable-tests? set-global
"cpu.arm.64.assembler" reload
"math.vectors.simd.intrinsics" reload
"cpu.arm.64" reload
{ "cpu.arm.64" "math.vectors.conversion" } [ dup require test-vocab ] each
"TEST FAILURES " write test-failures get length .
"COMPILER ERRORS " write compiler-errors get assoc-size .
test-failures get [ [ path>> print ] [ line#>> . ] [ error>> print-error ] tri ] each
compiler-errors get values [ print-error ] each flush
test-failures get empty? compiler-errors get assoc-empty? and 0 1 ? exit
