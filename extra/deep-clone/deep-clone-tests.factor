USING: assocs deep-clone kernel sequences tools.test ;

{ H{ { 1 "foo" } } H{ { 1 "boo" } } } [
    H{ { 1 "foo" } }  dup deep-clone
    CHAR: b 0 pick 1 of set-nth
] unit-test
