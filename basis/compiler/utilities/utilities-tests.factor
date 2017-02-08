USING: compiler.utilities kernel tools.test ;

{
    9
    H{ { 9 9 } { 44 9 } { 7 9 } }
} [
    7 H{ { 7 44 } { 44 9 } { 9 9 } } [ compress-path ] keep
] unit-test

{ H{ { 3 H{ { 1 1 } { 2 2 } } } } } [
    H{ } clone 1 3 pick conjoin-at 2 3 pick conjoin-at
] unit-test
