USING: accessors assocs compiler.errors debugger io kernel namespaces prettyprint sequences system tools.test ;
f restartable-tests? set-global
! Exercise callers exactly as saved by load-all, without reparsing or repair.
{ "images.loader.gtk" "images.loader" "ui.text" "ui.gadgets.editors" "euler.b-rep.triangulation" } [ test ] each
"TEST FAILURES " write test-failures get length .
"COMPILER ERRORS " write compiler-errors get assoc-size .
test-failures get [ error>> print-error ] each
test-failures get empty? compiler-errors get assoc-empty? and 0 1 ? exit
