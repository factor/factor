USING: graphs tools.test namespaces kernel sorting assocs ;
FROM: sets => members ;

H{ } "g" set
{ 1 2 3 } "v" set

[ ] [ "v" dup get "g" get add-vertex ] unit-test

[ { "v" } ] [ 1 "g" get at keys ] unit-test

H{
    { 1 H{ { 1 1 } { 2 2 } } }
    { 2 H{ { 3 3 } { 4 4 } } }
    { 4 H{ { 4 4 } { 5 5 } } }
} "g" set

[ { 2 3 4 5 } ] [
    2 [ "g" get at keys ] closure members natural-sort
] unit-test

H{ } "g" set

[ ] [
    "mary"
    H{ { "billy" "one" } { "joey" "two" } }
    "g" get add-vertex*
] unit-test

[ H{ { "mary" "one" } } ] [
    "billy" "g" get at
] unit-test

[ ] [
    "liz"
    H{ { "billy" "four" } { "fred" "three" } }
    "g" get add-vertex*
] unit-test

[ H{ { "mary" "one" } { "liz" "four" } } ] [
    "billy" "g" get at
] unit-test

[ ] [
    "mary"
    H{ { "billy" "one" } { "joey" "two" } }
    "g" get remove-vertex*
] unit-test

[ H{ { "liz" "four" } } ] [
    "billy" "g" get at
] unit-test
