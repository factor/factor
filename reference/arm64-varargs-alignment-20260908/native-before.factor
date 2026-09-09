USING: accessors assocs compiler.cfg.builder.alien compiler.cfg.builder.alien.params
compiler.errors compiler.units debugger io kernel namespaces parser prettyprint sequences system tools.test words ;
f restartable-tests? set-global

"resource:basis/compiler/tests/alien-varargs-outgoing.factor" run-test-file
"TEST FAILURES " write test-failures get length .
"COMPILER ERRORS " write compiler-errors get assoc-size .
:test-failures compiler-errors get values [ print-error ] each
 test-failures get empty? compiler-errors get assoc-empty? and 0 1 ? exit
