! Independent native callers exercise the ILP32D convention.
USING: kernel system tools.test ;
IN: compiler.tests.alien-riscv32.driver

cpu riscv.32? [
    "resource:basis/compiler/tests/fixtures/riscv32-abi.factor" run-test-file
    "resource:basis/compiler/tests/fixtures/riscv-struct-bounds.factor" run-test-file
    "cpu.riscv.32.abi" test
] when
