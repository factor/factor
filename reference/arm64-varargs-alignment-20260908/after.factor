USING: accessors assocs compiler.cfg.builder.alien compiler.cfg.builder.alien.params
compiler.errors compiler.units debugger io kernel namespaces parser prettyprint sequences system tools.test words ;
f restartable-tests? set-global
<< "/Users/erg/factor.worktrees/arm64-varargs-outgoing/reference/arm64-varargs-alignment-20260908/fix.factor" run-file >>
[ \ windows-arm64-varargs-call? [ varargs?>> >boolean ] define
  \ handle-macos-arm64-varargs [ drop f varargs-named-count set f compact-stack-params? set ] define
] with-compilation-unit
"/Users/erg/factor.worktrees/arm64-varargs-outgoing/reference/arm64-varargs-alignment-20260908/cases.factor" run-test-file
"TEST FAILURES " write test-failures get length .
"COMPILER ERRORS " write compiler-errors get assoc-size .
:test-failures compiler-errors get values [ print-error ] each
 test-failures get empty? compiler-errors get assoc-empty? and 0 1 ? exit
