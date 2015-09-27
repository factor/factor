
USING: assocs.extras kernel sequences tools.test ;

IN: assocs.extras

{ f } [ f { } deep-at ] unit-test
{ f } [ f { "foo" } deep-at ] unit-test
{ f } [ H{ } { 1 2 3 } deep-at ] unit-test
{ f } [ H{ { "a" H{ { "b" 1 } } } } { "a" "c" } deep-at ] unit-test
{ 1 } [ H{ { "a" H{ { "b" 1 } } } } { "a" "b" } deep-at ] unit-test
{ 4 } [ H{ { 1 H{ { 2 H{ { 3 4 } } } } } } { 1 2 3 } deep-at ] unit-test

{ H{ { 2 1 } { 4 3 } } } [ H{ { 1 2 } { 3 4 } } assoc-invert ] unit-test

{ H{ { "a" V{ 2 5 } } { "b" V{ 3 } } { "c" V{ 10 } } } }
[
    { H{ { "a" 2 } { "b" 3 } } H{ { "a" 5 } { "c" 10 } } }
    [ ] [ assoc-merge ] map-reduce
] unit-test

{ H{ } } [ H{ { 1 2 } } 2 over delete-value-at ] unit-test
{ H{ { 1 2 } } } [ H{ { 1 2 } } 3 over delete-value-at ] unit-test
