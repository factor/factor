USING: tools.test vocabs.files vocabs arrays grouping ;

{ t } [
    "kernel" vocab-files
    "kernel" lookup-vocab vocab-files
    "kernel" <vocab-link> vocab-files
    3array all-equal?
] unit-test

{ f } [ "not-a-valid-vocab" vocab-tests-path ] unit-test
{ "resource:core/kernel/kernel-tests.factor" } [ "kernel" vocab-tests-path ] unit-test
{ { "resource:core/kernel/kernel-tests.factor" } } [ "kernel" vocab-tests ] unit-test
