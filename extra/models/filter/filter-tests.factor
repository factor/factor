IN: models.filter.tests
USING: arrays generic kernel math models namespaces sequences assocs
tools.test models.filter ;

! Test multiple filters
3 <model> "x" set
"x" get [ 2 * ] <filter> dup "z" set
[ 1+ ] <filter> "y" set
[ ] [ "y" get activate-model ] unit-test
[ t ] [ "z" get "x" get model-connections memq? ] unit-test
[ 7 ] [ "y" get model-value ] unit-test
[ ] [ 4 "x" get set-model ] unit-test
[ 9 ] [ "y" get model-value ] unit-test
[ ] [ "y" get deactivate-model ] unit-test
[ f ] [ "z" get "x" get model-connections memq? ] unit-test

3 <model> "x" set
"x" get [ sq ] <filter> "y" set

4 "x" get set-model

"y" get activate-model
[ 16 ] [ "y" get model-value ] unit-test
"y" get deactivate-model
