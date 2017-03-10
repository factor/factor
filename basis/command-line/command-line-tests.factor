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
