USING: sorting.insertion sequences kernel tools.test ;

{ { { 1 1 } { 1 2 } { 2 0 } } } [
    { { 2 0 } { 1 1 } { 1 2 } } dup [ first ] insertion-sort
] unit-test
