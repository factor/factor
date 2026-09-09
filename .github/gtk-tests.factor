USING: assocs compiler.errors debugger environment io kernel namespaces
parser sequences system tools.test ui.backend vocabs.hierarchy ;
f restartable-tests? set-global
auto-use? off
"DISPLAY" os-env empty? [ "GTK tests require a display" throw ] when
"file-picker.linux" [ load ] [ test ] bi
"ui.backend.gtk2" test
:test-failures
compiler-errors get values [ print-error ] each
test-failures get empty? compiler-errors get assoc-empty? and 0 1 ? exit
