
USING: assocs kernel tools.completion tools.completion.private
tools.test ;

IN: tools.completion

[ f ] [ "abc" "def" fuzzy ] unit-test
[ V{ 4 5 6 } ] [ "set-nth" "nth" fuzzy ] unit-test

[ V{ V{ 0 } V{ 4 5 6 } } ] [ V{ 0 4 5 6 } runs ] unit-test

[ { "nth" "?nth" "set-nth" } ] [
    "nth" { "set-nth" "nth" "?nth" } dup zip completions keys
] unit-test

[ { "a" "b" "c" "d" "e" "f" "g" } ] [
    "" { "a" "b" "c" "d" "e" "f" "g" } dup zip completions keys
] unit-test
