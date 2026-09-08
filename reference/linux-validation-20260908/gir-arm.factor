USING: sequences vocabs.loader ;
"gobject-introspection.loader" reload
{ "gdk-pixbuf.ffi" "pango.ffi" "gtk2.ffi" } [ reload ] each
USING: accessors assocs compiler.errors debugger io kernel namespaces prettyprint sequences system tools.test ;
f restartable-tests? set-global
{ "gobject-introspection.loader" "gobject-introspection.ffi" "gdk-pixbuf.ffi" "pango.ffi" "gtk2.ffi" } [ test ] each
"TEST FAILURES " write test-failures get length .
"COMPILER ERRORS " write compiler-errors get assoc-size .
test-failures get [ error>> print-error ] each
test-failures get empty? compiler-errors get assoc-empty? and 0 1 ? exit
