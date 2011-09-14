IN: mason.release.tidy.tests
USING: mason.config mason.release.tidy namespaces sequences
system tools.test ;

[ f ] [
    macosx target-os [
        "Factor.app" useless-files member?
    ] with-variable
] unit-test

[ t ] [
    linux target-os [
        "Factor.app" useless-files member?
    ] with-variable
] unit-test
