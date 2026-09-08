USING: vocabs.loader vocabs.refresh ;
"gobject-introspection.loader" reload
refresh-all
USING: accessors assocs compiler.errors debugger io kernel namespaces prettyprint sequences system tools.test vocabs.loader ;
f restartable-tests? set-global
! Reparse callers once to repair references saved by the old FORGET: bindings.
{ "images.loader.gtk" "ui.text.pango" "ui.backend.gtk2" } [ reload ] each
{ "gobject-introspection.loader" "gobject-introspection.ffi" "gdk-pixbuf.ffi" "pango.ffi" "gtk2.ffi" "images.loader.gtk" "ui.text" "ui.gadgets.editors" "images.loader" "euler.b-rep.triangulation" } [ test ] each
"TEST FAILURES " write test-failures get length .
"COMPILER ERRORS " write compiler-errors get assoc-size .
test-failures get [ error>> print-error ] each
test-failures get empty? compiler-errors get assoc-empty? and 0 1 ? exit
