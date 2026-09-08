USING: kernel system tools.test ;
IN: compiler.tests.alien-linux-runtime.driver
os linux? [
    "resource:basis/compiler/tests/fixtures/linux-runtime.factor" run-test-file
] when
