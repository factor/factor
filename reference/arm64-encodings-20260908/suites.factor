USING: accessors assocs compiler.errors debugger io kernel namespaces
prettyprint sequences system tools.test vocabs.loader ;
f restartable-tests? set-global
"Reloading math.vectors.simd.intrinsics" print flush
"math.vectors.simd.intrinsics" reload
"Reloading cpu.arm.64.assembler" print flush
"cpu.arm.64.assembler" reload
"Reloading cpu.arm.64" print flush
"cpu.arm.64" reload
"Reloading math.vectors.simd.extensions" print flush
"math.vectors.simd.extensions" reload
{ "cpu.arm.64.assembler" "cpu.arm.64" "math.vectors.conversion"
  "math.vectors.simd.extensions" "cpu.arm.64.features" } [ dup "Testing " write print flush test "Suite finished" print flush ] each
"TEST FAILURES " write test-failures get length .
"COMPILER ERRORS " write compiler-errors get assoc-size .
test-failures get [ [ path>> print ] [ line#>> . ] [ error>> print-error ] tri ] each
compiler-errors get values [ print-error ] each flush
test-failures get empty? compiler-errors get assoc-empty? and 0 1 ? exit
