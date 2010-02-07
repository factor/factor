! (c)2010 Joe Groff bsd license
USING: sequences.inserters tools.test ;
IN: sequences.inserters.tests

[ V{ 1 2 "Three" "Four" "Five" } ] [
    { "three" "four" "five" }
    [ >title ] V{ 1 2 } clone <back-inserter> map-as
] unit-test

[ t ] [
    { "three" "four" "five" }
    [ >title ] V{ 1 2 } clone [ <back-inserter> map-as ] keep eq?
] unit-test

[ V{ 1 2 "Three" "Four" "Five" } ] [
    { { "Th" "ree" } { "Fo" "ur" } { "Fi" "ve" } }
    [ append ] V{ 1 2 } clone <back-inserter> assoc>map
] unit-test

[ t ] [
    { { "Th" "ree" } { "Fo" "ur" } { "Fi" "ve" } }
    [ append ] V{ 1 2 } clone [ <back-inserter> assoc>map ] keep eq?
] unit-test

[ V{ "Three" "Four" "Five" } ] [
    { "three" "four" "five" }
    [ >title ] V{ 1 2 } clone <replacer> map-as
] unit-test

[ t ] [
    { "three" "four" "five" }
    [ >title ] V{ 1 2 } clone [ <replacer> map-as ] keep eq?
] unit-test
