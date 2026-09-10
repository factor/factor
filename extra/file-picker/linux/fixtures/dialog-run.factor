USING: accessors assocs compiler.errors debugger io kernel namespaces parser
sequences system tools.test ui.backend ;
f restartable-tests? set-global
auto-use? off
ui-backend get name>> "gtk4-ui-backend" = [
    "resource:extra/file-picker/linux/fixtures/gtk4-dialog.factor"
] [ "resource:extra/file-picker/linux/fixtures/dialog.factor" ] if run-test-file
:test-failures
compiler-errors get values [ print-error ] each
test-failures get empty? compiler-errors get assoc-empty? and 0 1 ? exit
