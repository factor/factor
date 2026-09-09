USING: assocs compiler.errors debugger io kernel namespaces parser sequences system tools.test ;
f restartable-tests? set-global
"/Users/erg/factor.worktrees/arm64-varargs-outgoing/reference/arm64-varargs-outgoing-20260908/incoming/overrides.factor" run-file
"/Users/erg/factor.worktrees/arm64-varargs-outgoing/reference/arm64-varargs-outgoing-20260908/incoming/cases.factor" run-test-file
"/Users/erg/factor.worktrees/arm64-varargs-outgoing/reference/arm64-varargs-outgoing-20260908/incoming/vector.factor" run-test-file
:test-failures compiler-errors get values [ print-error ] each
test-failures get empty? compiler-errors get assoc-empty? and [ 0 ] [ 1 ] if exit
