USING: xmode.catalog tools.test hashtables assocs
kernel sequences io ;

{ t } [ modes hashtable? ] unit-test

{ } [
    modes keys [
        dup print flush load-mode drop reset-modes
    ] each
] unit-test
