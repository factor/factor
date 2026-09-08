! Keep unsupported-platform declarations out of the parser/compiler entirely.
USING: kernel system tools.test ;
IN: compiler.tests.alien-arm64-abi.driver

cpu arm.64? os macos? and os linux? or [
    "resource:basis/compiler/tests/fixtures/arm64-abi.factor" run-test-file
] when
