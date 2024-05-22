USING: command-line namespaces tools.test ;

{ f { "a" "b" "c" } } [
    { "factor" "-run=test-voc" "a" "b" "c" } parse-command-line
    script get command-line get
] unit-test

{ f { "-a" "b" "c" } } [
    { "factor" "-run=test-voc" "-a" "b" "c" } parse-command-line
    script get command-line get
] unit-test

{ f { "a" "-b" "c" } } [
    { "factor" "-run=test-voc" "a" "-b" "c" } parse-command-line
    script get command-line get
] unit-test

{ f { "a" "b" "-c" } } [
    { "factor" "-run=test-voc" "a" "b" "-c" } parse-command-line
    script get command-line get
] unit-test

{ "a" { "b" "c" } } [
    { "factor" "a" "b" "c" } parse-command-line
    script get command-line get
] unit-test

{ "a" { "b" "c" } } [
    { "factor" "-foo" "a" "b" "c" } parse-command-line
    script get command-line get
] unit-test

{ "a:b:c" } [ { "factor" "-roots=a:b:c" } parse-command-line
    "roots" get-global
] unit-test

{ { "arg1" "arg2" } t "12" f } [
    { "-foo" "-bar=12" "-no-baz" "arg1" "arg2" }
    command-line-options
    "foo" get "bar" get "baz" get
] unit-test
