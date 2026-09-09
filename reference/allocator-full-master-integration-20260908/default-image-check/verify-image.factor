USING: accessors assocs compiler.errors compiler.cfg.register-allocation
compiler.cfg.register-allocation.rematerialization
compiler.cfg.linear-scan.allocation.state compiler.cfg.value-numbering
compiler.test io kernel kernel.private math memory namespaces sequences tools.test
tools.test.private words ;
IN: allocator-speed-image-validation

f restartable-tests? set-global
t check-allocation? set-global
current-register-allocator linear-scan-allocator assert=
global-value-numbering? get f assert=
rematerialize-constants? get f assert=
compiler-errors get assoc-size 0 assert=

{ 42 } [ 19 23 [ { fixnum fixnum } declare + ] compile-call ] unit-test
{ 7.5 } [ 1.5 2.0 3.0 [ * + ] compile-call ] unit-test
{ { 1 2 3 } } [ { 1 2 3 } [ dup gc drop ] compile-call ] unit-test
{ 4950 } [ 100 [ <iota> 0 [ + ] reduce ] compile-call ] unit-test

test-failures get empty? t assert=
compiler-errors get assoc-size 0 assert=
"SPEED image-verification=passed allocator=linear-scan gvn=off rematerialization=off" print
