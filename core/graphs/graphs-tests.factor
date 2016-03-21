USING: assocs graphs kernel namespaces sets sorting tools.test ;

H{ } "g" set
{ 1 2 3 } "v" set

{ } [ "v" dup get "g" get add-vertex ] unit-test

{ { "v" } } [ 1 "g" get at members ] unit-test

H{
    { 1 HS{ 1 2 } }
    { 2 HS{ 3 4 } }
    { 4 HS{ 4 5 } }
} "g" set

{ { 2 3 4 5 } } [
    2 [ "g" get at members ] closure members natural-sort
] unit-test
