USING: io.directories mason.config mason.release.tidy namespaces
sequences system tools.test ;
IN: mason.release.tidy.tests

[ f ] [
    macos target-os [
        "Factor.app" useless-files member?
    ] with-variable
] unit-test

[ t ] [
    linux target-os [
        "Factor.app" useless-files member?
    ] with-variable
] unit-test
