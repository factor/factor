USING: assocs compiler.errors debugger io kernel kernel.private namespaces
sequences system tools.test vocabs words ;
f restartable-tests? set-global
{ 3 } [ CALLBACK-STUB special-object length ] unit-test
{ t } [ "alien-callback-varargs" "alien" lookup-word "special" word-prop >boolean ] unit-test
{ t } [ "alien-callback-varargs" "alien" lookup-word "no-compile" word-prop ] unit-test
"resource:basis/compiler/tests/alien-varargs.factor" run-test-file
"resource:basis/compiler/tests/alien-varargs-outgoing.factor" run-test-file
test-failures get empty? compiler-errors get assoc-empty? and
[ "Old seed full-bootstrap native varargs tests passed" print 0 ]
[ :test-failures compiler-errors get values [ print-error ] each 1 ] if flush exit
