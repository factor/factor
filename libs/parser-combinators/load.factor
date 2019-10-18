REQUIRES: libs/lazy-lists libs/sequences ;
PROVIDE: libs/parser-combinators
{ +files+ {
    "parser-combinators.factor"
    "parser-combinators.facts"
    "simple-parsers.factor"
    "simple-parsers.facts"
    "search-replace.factor"
    "search-replace.facts"
} }
{ +tests+ {
    "tests.factor"
} } ;