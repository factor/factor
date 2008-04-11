IN: tools.vocabs.tests
USING: tools.test tools.vocabs namespaces continuations ;

[ ] [
    changed-vocabs get-global
    f changed-vocabs set-global
    [ "kernel" changed-vocab ] [ changed-vocabs set-global ] [ ] cleanup
] unit-test
