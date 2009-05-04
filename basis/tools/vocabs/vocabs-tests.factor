IN: tools.vocabs.tests
USING: continuations namespaces tools.test tools.vocabs tools.vocabs.private ;

[ ] [
    changed-vocabs get-global
    f changed-vocabs set-global
    [ t ] [ "kernel" changed-vocab? ] unit-test
    [ "kernel" changed-vocab ] [ changed-vocabs set-global ] [ ] cleanup
] unit-test

[ t ] [ "some-vocab" valid-vocab-dirname ] unit-test
[ f ] [ ".git" valid-vocab-dirname ] unit-test
