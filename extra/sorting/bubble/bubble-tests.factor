USING: kernel sorting.bubble tools.test ;

{ { } } [ { } dup bubble-sort! ] unit-test
{ { 1 } } [ { 1 } dup bubble-sort! ] unit-test
{ { 1 2 3 4 5 } } [ { 1 4 2 5 3 } dup bubble-sort! ] unit-test
