USING: kernel tools.test ;
IN: sorting.quick

{ { } } [ { } dup quicksort ] unit-test
{ { 1 } } [ { 1 } dup quicksort ] unit-test
{ { 1 2 3 4 5 } } [ { 1 4 2 5 3 } dup quicksort ] unit-test
