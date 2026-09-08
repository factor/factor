USING: namespaces parser vocabs vocabs.loader vocabs.refresh ;
<< auto-use? off "cpu.architecture" reload "alien.c-types" reload
   "alien" refresh "stack-checker" refresh
   "compiler" refresh "cpu" refresh >>
USING: accessors assocs combinators command-line compiler.cfg.checker
compiler.cfg.linear-scan.allocation.state compiler.cfg.register-allocation
compiler.cfg.register-allocation.backtracking compiler.cfg.register-allocation.chordal
compiler.cfg.register-allocation.greedy compiler.cfg.value-numbering
compiler.errors cpu.x86.features debugger io io.files.temp kernel
namespaces parser prettyprint random random.mersenne-twister sequences
system tools.test tools.test.fuzz vocabs vocabs.loader ;

"resource:logs/simd-x64/tmp" current-temp-directory set-global
auto-use? off
restartable-tests? off
verbose-tests? off
check-allocation? on
check-ssa? on
20260908 <mersenne-twister> random-generator set
"global" command-line get member? global-value-numbering? set
command-line get first {
    { "linear-scan" [ linear-scan-allocator ] }
    { "greedy" [ greedy-allocator ] }
    { "backtracking" [ backtracking-allocator ] }
    { "chordal" [ chordal-allocator ] }
} case register-allocator set
"SSE " write sse-version .
"ALLOCATOR " write current-register-allocator .
"GLOBAL GVN " write global-value-numbering? get . flush
{
    "cpu.x86" "cpu.x86.assembler" "cpu.x86.64" "cpu.x86.features"
    "math.vectors.simd" "math.vectors.simd.intrinsics"
    "math.vectors.simd.cords" "math.vectors.simd.extensions"
    "math.vectors.conversion" "math.matrices.simd" "random.sfmt"
    "compiler.cfg.intrinsics.simd" "compiler.tree.propagation.simd"
    "compiler.cfg.value-numbering.simd"
} [ require ] each
{
    "cpu.x86" "math.vectors.simd" "math.vectors.conversion" "random.sfmt"
    "math.matrices.simd" "compiler.cfg.intrinsics.simd"
    "compiler.tree.propagation.simd" "compiler.cfg.value-numbering.simd"
} [ dup print flush test ] each
"TEST FAILURES " write test-failures get length .
"COMPILER ERRORS " write compiler-errors get assoc-size .
test-failures get [ error>> print-error ] each
compiler-errors get values [ print-error ] each
test-failures get empty? compiler-errors get assoc-empty? and 0 1 ? exit
