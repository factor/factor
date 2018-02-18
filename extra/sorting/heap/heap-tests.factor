USING: kernel sequences sorting.heap tools.test ;

{ { } } [ { } heapsort ] unit-test
{ { 1 } } [ { 1 } heapsort ] unit-test
{ { 1 2 3 4 5 } } [ { 1 4 2 5 3 } heapsort ] unit-test

{
    { "fred" "dino" "wilma" "betty" "barney" "pebbles" "bamm-bamm" }
} [
    { "fred" "wilma" "pebbles" "dino" "barney" "betty" "bamm-bamm" }
    [ length ] heapsort-with
] unit-test
