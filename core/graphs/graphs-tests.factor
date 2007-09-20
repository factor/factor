USING: graphs tools.test namespaces kernel sorting assocs ;

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
    2 [ "g" get at ] closure keys natural-sort 
] unit-test
