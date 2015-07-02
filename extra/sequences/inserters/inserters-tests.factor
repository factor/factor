! (c)2010 Joe Groff bsd license
USING: assocs kernel sequences sequences.inserters tools.test
unicode.case ;
IN: sequences.inserters.tests

[ V{ 1 2 "Three" "Four" "Five" } ] [
    { "three" "four" "five" }
    [ >title ] V{ 1 2 } clone <appender> map-as
] unit-test

[ t ] [
    { "three" "four" "five" }
    [ >title ] V{ 1 2 } clone [ <appender> map-as ] keep eq?
] unit-test

[ V{ 1 2 "Three" "Four" "Five" } ] [
    { { "Th" "ree" } { "Fo" "ur" } { "Fi" "ve" } }
    [ append ] V{ 1 2 } clone <appender> assoc>map
] unit-test

[ t ] [
    { { "Th" "ree" } { "Fo" "ur" } { "Fi" "ve" } }
    [ append ] V{ 1 2 } clone [ <appender> assoc>map ] keep eq?
] unit-test

[ V{ "Three" "Four" "Five" } ] [
    { "three" "four" "five" }
    [ >title ] V{ 1 2 } clone <replacer> map-as
] unit-test

[ t ] [
    { "three" "four" "five" }
    [ >title ] V{ 1 2 } clone [ <replacer> map-as ] keep eq?
] unit-test

[ V{ "Three" "Four" "Five" } ] [
    { { "Th" "ree" } { "Fo" "ur" } { "Fi" "ve" } }
    [ append ] V{ 1 2 } clone <replacer> assoc>map
] unit-test

[ t ] [
    { { "Th" "ree" } { "Fo" "ur" } { "Fi" "ve" } }
    [ append ] V{ 1 2 } clone [ <replacer> assoc>map ] keep eq?
] unit-test
