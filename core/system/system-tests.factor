USING: arrays kernel sequences system tools.test ;

{ { t t t } } [
    version-info
    vm-version vm-compiler vm-compile-time 3array
    [ subseq-of? ] with map
] unit-test
