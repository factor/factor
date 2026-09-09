USING: assocs compiler.errors debugger io kernel namespaces sequences
system tools.test vocabs.loader ;
f restartable-tests? set-global
"x11.syntax" reload
"x11.xlib" reload
"resource:basis/x11/syntax/syntax-tests.factor" run-test-file
"resource:basis/x11/xlib/xlib-tests.factor" run-test-file
compiler-errors get values [ print-error ] each
test-failures get empty? compiler-errors get assoc-empty? and
[ "X11 parser checks passed" print 0 ] [ :test-failures 1 ] if exit
