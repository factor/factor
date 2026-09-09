USING: alien alien.libraries assocs compiler.errors debugger io kernel kernel.private
namespaces sequences stack-checker.alien system tools.test vocabs.loader ;
"stack-checker.alien" reload
f restartable-tests? set-global
{ f } [ "arm64_variadic_callbacks_supported" f dlsym ] unit-test
{ 2 } [ CALLBACK-STUB special-object length ] unit-test
[ check-variadic-callback-runtime ] [ variadic-callback-runtime-required? ] must-fail-with
{ 2 } [ CALLBACK-STUB special-object length ] unit-test
test-failures get empty? compiler-errors get assoc-empty? and
[ "Old VM is rejected before template mutation" print 0 ]
[ :test-failures compiler-errors get values [ print-error ] each 1 ] if flush exit
