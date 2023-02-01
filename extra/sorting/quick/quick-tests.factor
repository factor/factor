USING: kernel sequences sorting.quick tools.test ;

{ { } } [ { } dup sort! ] unit-test
{ { 1 } } [ { 1 } dup sort! ] unit-test
{ { 1 2 3 4 5 } } [ { 1 4 2 5 3 } dup sort! ] unit-test

{
    { "dino" "fred" "wilma" "betty" "barney" "pebbles" "bamm-bamm" }
} [
    { "fred" "wilma" "pebbles" "dino" "barney" "betty" "bamm-bamm" }
    dup [ length ] sort-by!
] unit-test
