USING: arrays kernel sequences system tools.test ;

{ { t t t } } [
    vm-info
    vm-version vm-compiler vm-compile-time 3array
    [ subseq-of? ] with map
] unit-test
