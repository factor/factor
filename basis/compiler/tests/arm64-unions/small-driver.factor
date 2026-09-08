USING: io kernel namespaces tools.test ;
IN: compiler.tests.arm64-unions
"require-varargs-small" get [ au_small_available 1 assert= ] when
au_small_available 1 = [
    "resource:basis/compiler/tests/arm64-unions/small.factor" run-test-file
] [ "Half/BF16 homogeneous union C fixtures unavailable on this compiler." print ] if
