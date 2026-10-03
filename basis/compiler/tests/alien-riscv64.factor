USING: kernel system tools.test ;
IN: compiler.tests.alien-riscv64.driver

cpu riscv.64? [
    "resource:basis/compiler/tests/fixtures/riscv64-abi.factor" run-test-file
    "resource:basis/compiler/tests/fixtures/riscv-struct-bounds.factor" run-test-file
] when
