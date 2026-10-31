USING: namespaces tldr tldr.private tools.test ;
IN: tldr.tests

{ "freebsd" } [
    "freebsd" tldr-platform [
        H{ { "platform" { "common" "freebsd" } } } platform
    ] with-variable
] unit-test

{ "common" } [
    "freebsd" tldr-platform [
        H{ { "platform" { "common" "linux" } } } platform
    ] with-variable
] unit-test
