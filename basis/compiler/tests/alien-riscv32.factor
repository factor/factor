! Independent native callers exercise the ILP32D convention.
USING: kernel system tools.test ;
IN: compiler.tests.alien-riscv32.driver

cpu riscv.32? [
    "resource:basis/compiler/tests/fixtures/riscv32-abi.factor" run-test-file
    "resource:basis/compiler/tests/fixtures/riscv-struct-bounds.factor" run-test-file
    os linux? [
        "resource:basis/compiler/tests/fixtures/riscv-linux-layout.factor" run-test-file
    ] when
    "cpu.riscv.32.abi" test
] when
