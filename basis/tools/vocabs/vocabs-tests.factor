IN: tools.vocabs.tests
USING: tools.test tools.vocabs namespaces continuations ;

[ ] [
    changed-vocabs get-global
    f changed-vocabs set-global
    [ t ] [ "kernel" changed-vocab? ] unit-test
    [ "kernel" changed-vocab ] [ changed-vocabs set-global ] [ ] cleanup
] unit-test
