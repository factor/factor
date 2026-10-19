USING: alien alien.c-types alien.libraries alien.syntax compiler compiler.test compiler.units
io kernel math math.bitwise namespaces sequences tools.test words ;
IN: cpu.hppa.longlong-return
"hppa-return-fixture" "./libfactor-ffi-test.so" cdecl add-library
LIBRARY: hppa-return-fixture
FUNCTION: longlong ffi_test_21 ( long a, long b )
FUNCTION: ulonglong ffi_test_38 ( ulonglong a, ulonglong b )
{ ffi_test_21 ffi_test_38 } compile
{ t } [ { ffi_test_21 ffi_test_38 } [ word-optimized? ] all? ] unit-test
{ 121932631112635269 } [ 123456789 987654321 ffi_test_21 ] unit-test
{ t } [ 31 2^ 32 2^ ffi_test_38 63 2^ = ] unit-test
test-failures get empty? t assert=
"Optimized signed/unsigned GNU HPPA long-long returns passed" print
