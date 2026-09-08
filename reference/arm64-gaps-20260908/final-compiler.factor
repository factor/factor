USING: accessors assocs compiler.errors debugger io kernel namespaces prettyprint sequences system tools.test ;
f restartable-tests? set-global
USING: compiler.cfg.checker compiler.cfg.linear-scan.allocation.state ;
check-ssa? on
check-allocation? on
"compiler" test

"TEST FAILURES " write test-failures get length .
"COMPILER ERRORS " write compiler-errors get assoc-size .
test-failures get [ error>> print-error ] each
compiler-errors get values [ print-error ] each flush
test-failures get empty? compiler-errors get assoc-empty? and 0 1 ? exit
