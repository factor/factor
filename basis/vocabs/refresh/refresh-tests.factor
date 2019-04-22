USING: vocabs.refresh tools.test continuations namespaces ;

{ } [
    changed-vocabs get-global
    f changed-vocabs set-global
    { t } [ "kernel" changed-vocab? ] unit-test
    [ "kernel" changed-vocab ] [ changed-vocabs set-global ] finally
] unit-test
