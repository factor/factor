USING: kernel system tools.test ;
IN: compiler.tests.alien-linux-regressions.driver
os linux? os macos? or [
    "resource:basis/compiler/tests/fixtures/linux-regressions.factor" run-test-file
] when
