USING: arrays generic kernel math models namespaces sequences assocs
tools.test models.arrow accessors ;

3 <model> "x" set
"x" get [ 2 * ] <arrow> dup "z" set
[ 1 + ] <arrow> "y" set
{ } [ "y" get activate-model ] unit-test
{ t } [ "z" get "x" get connections>> member-eq? ] unit-test
{ 7 } [ "y" get value>> ] unit-test
{ } [ 4 "x" get set-model ] unit-test
{ 9 } [ "y" get value>> ] unit-test
{ } [ "y" get deactivate-model ] unit-test
{ f } [ "z" get "x" get connections>> member-eq? ] unit-test

3 <model> "x" set
"x" get [ sq ] <arrow> "y" set

4 "x" get set-model

"y" get activate-model
{ 16 } [ "y" get value>> ] unit-test
"y" get deactivate-model
