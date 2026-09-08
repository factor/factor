USING: namespaces parser vocabs vocabs.loader vocabs.refresh ;
<< auto-use? off "cpu.architecture" reload "alien.c-types" reload
   "alien" refresh "stack-checker" refresh
   "compiler" refresh "cpu" refresh >>
USING: accessors assocs compiler.errors debugger io kernel namespaces
parser prettyprint sequences system tools.test vocabs.loader vocabs.refresh ;
auto-use? off restartable-tests? off verbose-tests? off
"math.vectors.simd.intrinsics" require
"math.vectors.simd.intrinsics" test
"TEST FAILURES " write test-failures get length .
"COMPILER ERRORS " write compiler-errors get assoc-size .
test-failures get [ error>> print-error ] each
compiler-errors get values [ print-error ] each
test-failures get empty? compiler-errors get assoc-empty? and 0 1 ? exit
