USING: assocs sequences.abbrev tools.test ;
IN: sequences.abbrev.tests

[ { "hello" "help" } ] [
    "he" { "apple" "hello" "help" } abbrev at
] unit-test

[ f ] [
    "he" { "apple" "hello" "help" } unique-abbrev at
] unit-test

[ { "apple" } ] [
    "a" { "apple" "hello" "help" } abbrev at
] unit-test

[ { "apple" } ] [
    "a" { "apple" "hello" "help" } unique-abbrev at
] unit-test

[ f ] [
    "a" { "hello" "help" } abbrev at
] unit-test

[ f ] [
    "a" { "hello" "help" } unique-abbrev at
] unit-test
