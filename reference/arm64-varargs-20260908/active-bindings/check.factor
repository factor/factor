USING: assocs compiler.errors debugger io kernel namespaces parser
sequences system tools.test unix.ffi curl.ffi openssl.libcrypto ;
f restartable-tests? set-global
"resource:basis/unix/ffi/ffi.factor" run-file
"resource:extra/curl/ffi/ffi.factor" run-file
"resource:basis/openssl/libcrypto/libcrypto.factor" run-file
{
    "resource:basis/unix/ffi/ffi-tests.factor"
    "resource:extra/curl/ffi/ffi-tests.factor"
    "resource:basis/openssl/libcrypto/tests/varargs.factor"
} [ run-test-file ] each
:test-failures compiler-errors get values [ print-error ] each
 test-failures get empty? compiler-errors get assoc-empty? and
 [ 0 ] [ 1 ] if exit
