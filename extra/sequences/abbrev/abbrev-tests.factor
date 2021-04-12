USING: assocs sequences.abbrev tools.test ;

{ V{ "hello" "help" } } [
    "he" { "apple" "hello" "help" } abbrev at
] unit-test

{ f } [
    "he" { "apple" "hello" "help" } unique-abbrev at
] unit-test

{ V{ "apple" } } [
    "a" { "apple" "hello" "help" } abbrev at
] unit-test

{ V{ "apple" } } [
    "a" { "apple" "hello" "help" } unique-abbrev at
] unit-test

{ f } [
    "a" { "hello" "help" } abbrev at
] unit-test

{ f } [
    "a" { "hello" "help" } unique-abbrev at
] unit-test
