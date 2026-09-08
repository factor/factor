! Keep unsupported-platform declarations out of the parser/compiler entirely.
USING: kernel system tools.test ;
IN: compiler.tests.alien-arm64-abi.driver

f [
    "resource:does-not-exist-platform-fixture.factor" run-test-file
] when
