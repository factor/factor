USING: arrays generic kernel math models namespaces sequences assocs
tools.test models.compose accessors ;
IN: models.compose.tests

! Test compose
[ ] [
    1 <model> "a" set
    2 <model> "b" set
    "a" get "b" get 2array <compose> "c" set
] unit-test

[ ] [ "c" get activate-model ] unit-test

[ { 1 2 } ] [ "c" get value>> ] unit-test

[ ] [ 3 "b" get set-model ] unit-test

[ { 1 3 } ] [ "c" get value>> ] unit-test

[ ] [ { 4 5 } "c" get set-model ] unit-test

[ { 4 5 } ] [ "c" get value>> ] unit-test

[ ] [ "c" get deactivate-model ] unit-test
