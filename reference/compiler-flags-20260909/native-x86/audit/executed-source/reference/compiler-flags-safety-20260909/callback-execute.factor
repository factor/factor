! Executed after explicit recompilation of the fixture vocabulary under each setting.
USING: compiler.tests.alien-large-return alien destructors kernel tools.test ;
{ 6 15 24 } [
    1 2 3 4 5 6 7 8 9 ffi_test_large_return large-return-values
] unit-test
{ 45 } [
    large-return-callback [ ffi_test_large_return_callback ] with-callback
] unit-test
{ 45 } [
    nested-large-return-callback [ ffi_test_large_return_callback ] with-callback
] unit-test
