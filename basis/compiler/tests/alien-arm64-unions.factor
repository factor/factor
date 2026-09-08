USING: cpu.architecture kernel system tools.test ;
IN: compiler.tests.alien-arm64-unions-driver
cpu arm.64? [
    "resource:basis/compiler/tests/arm64-unions/cases.factor" run-test-file
    "resource:basis/compiler/tests/arm64-unions/callbacks.factor" run-test-file
    "resource:basis/compiler/tests/arm64-unions/small-driver.factor" run-test-file
] when
