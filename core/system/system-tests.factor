USING: arrays sequences system tools.test ;

{ { t t t } } [
    version-info
    vm-version vm-compiler vm-compile-time 3array
    [ subsequence? ] with map
] unit-test
