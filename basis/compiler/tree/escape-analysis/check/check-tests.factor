USING: compiler.tree.escape-analysis.check tools.test accessors kernel
kernel.private math compiler.tree.builder compiler.tree.normalization
compiler.tree.propagation compiler.tree.cleanup ;
IN: compiler.tree.escape-analysis.check.tests

: test-checker ( quot -- ? )
    build-tree normalize propagate cleanup-tree run-escape-analysis? ;

{ t } [
    [ { complex } declare [ real>> ] [ imaginary>> ] bi ]
    test-checker
] unit-test

{ t } [
    [ complex boa [ real>> ] [ imaginary>> ] bi ]
    test-checker
] unit-test

{ t } [
    [ [ complex boa [ real>> ] [ imaginary>> ] bi ] when ]
    test-checker
] unit-test

{ f } [
    [ swap 1 2 ? ]
    test-checker
] unit-test
