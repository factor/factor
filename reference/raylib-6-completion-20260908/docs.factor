USING: alien alien.libraries assocs compiler.errors kernel namespaces
parser prettyprint sequences system tools.test vocabs.loader ;
f restartable-tests? set-global
f load-help? set-global
"raylib" reload
"resource:extra/raylib/raylib-docs.factor" run-test-file
:test-failures
compiler-errors get assoc-size .
test-failures get empty? compiler-errors get assoc-empty? and [ 0 ] [ 1 ] if exit
