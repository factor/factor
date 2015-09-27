USING: kernel tools.destructors tools.test destructors namespaces ;
IN: tools.destructors.tests

f debug-leaks? set-global

[ [ 3 throw ] leaks. ] must-fail

{ f } [ debug-leaks? get-global ] unit-test

{ } [ [ ] leaks. ] unit-test

{ f } [ debug-leaks? get-global ] unit-test
