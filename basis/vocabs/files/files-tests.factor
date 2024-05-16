IN: vocabs.files.tests
USING: tools.test vocabs.files vocabs arrays grouping ;

{ t } [
    "kernel" vocab-files
    "kernel" lookup-vocab vocab-files
    "kernel" <vocab-link> vocab-files
    3array all-equal?
] unit-test

{ f } [ "foo" vocab-tests-path ] unit-test { "resource:core/kernel/kernel-tests.factor" }
[ "kernel" vocab-tests-path ] unit-test

{ { "resource:core/kernel/kernel-tests.factor" } } [ "kernel" vocab-tests ] unit-test
