USING: arrays generic kernel math models namespaces sequences assocs
tools.test models.mapping accessors make ;

! Test mapping
{ } [
    [
        1 <model> "one" ,,
        2 <model> "two" ,,
    ] H{ } make
    <mapping> "m" set
] unit-test

{ } [ "m" get activate-model ] unit-test

{ H{ { "one" 1 } { "two" 2 } } } [
    "m" get value>>
] unit-test

{ } [
    H{ { "one" 3 } { "two" 4 } }
    "m" get set-model
] unit-test

{ H{ { "one" 3 } { "two" 4 } } } [
    "m" get value>>
] unit-test

{ H{ { "one" 5 } { "two" 4 } } } [
    5 "one" "m" get assoc>> at set-model
    "m" get value>>
] unit-test

{ } [ "m" get deactivate-model ] unit-test
