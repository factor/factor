USING: make sequences tools.test ;

{ "ABCD" } [ [ "ABCD" [ , ] each ] "" make ] unit-test

{ H{ { "key" "value" } } }
[ [ "value" "key" ,, ] H{ } make ] unit-test

{ { 1 2 3 } } [ [ { 1 } % { 2 3 } % ] { } make ] unit-test

{ { { 1 2 } } } [ [ 2 1 ,, ] { } make ] unit-test

{ H{ { 3 6 } } } [ [ 1 3 ,, 5 3 ,+ ] H{ } make ] unit-test

{ H{ { 1 V{ 2 3 } } } } [ [ 2 1 ,% 3 1 ,% ] H{ } make ] unit-test

{ H{ { 1 2 } { 2 3 } } } [
    [ H{ { 1 2 } } %%
      H{ { 2 3 } } %% ] H{ } make
] unit-test

{ { } } [ [ ] { 1 2 3 } make ] unit-test
