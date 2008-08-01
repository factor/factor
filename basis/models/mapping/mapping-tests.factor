IN: models.mapping.tests
USING: arrays generic kernel math models namespaces sequences assocs
tools.test models.mapping ;

! Test mapping
[ ] [
    [
        1 <model> "one" set
        2 <model> "two" set
    ] H{ } make-assoc
    <mapping> "m" set
] unit-test

[ ] [ "m" get activate-model ] unit-test

[ H{ { "one" 1 } { "two" 2 } } ] [
    "m" get model-value
] unit-test

[ ] [
    H{ { "one" 3 } { "two" 4 } } 
    "m" get set-model
] unit-test

[ H{ { "one" 3 } { "two" 4 } } ] [
    "m" get model-value
] unit-test

[ H{ { "one" 5 } { "two" 4 } } ] [
    5 "one" "m" get mapping-assoc at set-model
    "m" get model-value
] unit-test

[ ] [ "m" get deactivate-model ] unit-test
