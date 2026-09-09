USING: accessors assocs compiler.errors compiler.cfg.builder.alien compiler.units
 debugger io kernel namespaces parser sequences stack-checker.alien system tools.test words ;

f restartable-tests? set-global
! Exercise Windows parameter lowering without changing the macOS runtime ABI.
[
  \ handle-macos-arm64-varargs [ drop f varargs-named-count set ] define
] with-compilation-unit
"resource:reference/arm64-varargs-outgoing-20260908/windows-cases.factor" run-test-file

:test-failures compiler-errors get values [ print-error ] each
test-failures get empty? compiler-errors get assoc-empty? and [ 0 ] [ 1 ] if exit
