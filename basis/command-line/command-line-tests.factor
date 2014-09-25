USING: namespaces splitting tools.test ;
IN: command-line

{ f { "a" "b" "c" } } [
    { "-run=test-voc" "a" "b" "c" } parse-command-line
    script get command-line get
] unit-test

{ f { "-a" "b" "c" } } [
    { "-run=test-voc" "-a" "b" "c" } parse-command-line
    script get command-line get
] unit-test

{ f { "a" "-b" "c" } } [
    { "-run=test-voc" "a" "-b" "c" } parse-command-line
    script get command-line get
] unit-test

{ f { "a" "b" "-c" } } [
    { "-run=test-voc" "a" "b" "-c" } parse-command-line
    script get command-line get
] unit-test

{ "a" { "b" "c" } } [
    { "a" "b" "c" } parse-command-line
    script get command-line get
] unit-test

{ "a" { "b" "c" } } [
    { "-foo" "a" "b" "c" } parse-command-line
    script get command-line get
] unit-test
