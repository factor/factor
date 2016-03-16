USING: arrays sequences system tools.test ;
IN: system.tests

{ { t t t } } [
    vm-version vm-compiler vm-compile-time 3array
    [ version-info subseq? ] map
] unit-test
