USING: accessors assocs compiler.errors debugger io kernel namespaces
prettyprint sequences system tools.test vocabs.loader ;
{ "compiler.cfg.value-numbering.graph" "compiler.cfg.value-numbering.folding" "compiler.cfg.value-numbering" } [ reload ] each
f restartable-tests? set-global
{ "compiler.cfg.value-numbering" "compiler.cfg.representations"
  "compiler.cfg.linear-scan" "compiler.cfg.ssa" } [ dup print flush test ] each
"TEST FAILURES " write test-failures get length .
"COMPILER ERRORS " write compiler-errors get assoc-size .
test-failures get [ error>> print-error ] each
compiler-errors get values [ print-error ] each flush
test-failures get empty? compiler-errors get assoc-empty? and 0 1 ? exit
