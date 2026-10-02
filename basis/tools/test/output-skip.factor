USING: kernel namespaces tools.test ;
IN: tools.test.output-fixture
f long-unit-tests-enabled? [
    { 42 } [ 42 ] long-unit-test
] with-variable
