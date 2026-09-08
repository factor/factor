USING: accessors debugger io kernel namespaces prettyprint sequences system tools.test ;
f restartable-tests? set-global
{ "gdk-pixbuf" "pango" "gtk2" } [
 "/home/erg/factor-linux-targeted-20260908/basis/" swap "/ffi/ffi-tests.factor" 3append run-test-file
] each
"EXPECTED BASELINE FAILURES " write test-failures get length .
test-failures get [ error>> print-error ] each
0 exit
