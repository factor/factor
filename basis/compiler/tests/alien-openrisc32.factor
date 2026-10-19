! Run the OpenRISC ABI tests only on their native target.
USING: kernel system tools.test ;
IN: compiler.tests.alien-openrisc32.driver

cpu openrisc.32? [
    "resource:basis/compiler/tests/fixtures/openrisc32-abi.factor" run-test-file
    "cpu.openrisc.32.abi" test
] when
