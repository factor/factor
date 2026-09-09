USING: assocs compiler.errors debugger io kernel namespaces parser
sequences system tools.test ;
f restartable-tests? set-global
auto-use? off
"resource:extra/file-picker/linux/fixtures/dialog.factor" run-test-file
:test-failures
compiler-errors get values [ print-error ] each
test-failures get empty? compiler-errors get assoc-empty? and 0 1 ? exit
