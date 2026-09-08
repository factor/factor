USING: accessors assocs compiler.errors debugger io kernel namespaces
parser prettyprint sequences system tools.test vocabs.loader ;
f restartable-tests? set-global
{ "cpu.arm.64.assembler" "compiler.cfg.multiply-negate" } [ dup print flush test ] each
"reference/arm64-gap-isa-20260908/new-tests.factor" run-file
"TEST FAILURES " write test-failures get length .
"COMPILER ERRORS " write compiler-errors get assoc-size .
test-failures get [ error>> print-error ] each
compiler-errors get values [ print-error ] each flush
test-failures get empty? compiler-errors get assoc-empty? and 0 1 ? exit
