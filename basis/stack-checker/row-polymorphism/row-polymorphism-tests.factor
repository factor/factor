USING: continuations effects kernel locals math sequences
stack-checker stack-checker.errors stack-checker.row-polymorphism
tools.test ;
IN: stack-checker.row-polymorphism.tests

:: compatible-rows? ( constraints -- ? )
    H{ } clone :> vars
    constraints [ first2 [ vars ] 2dip check-variables ] all? ;

! #138: a shallow quotation can share an already-bound row.
: row-cleanup ( ..a try: ( ..a -- ..a ) always: ( ..a -- ..b ) error: ( ..b -- ..b ) -- ..b )
    cleanup ; inline

{ 1 1 } [ [ 1 + ] [ ] [ ] row-cleanup ] must-infer-as
{ 42 } [ 41 [ 1 + ] [ ] [ ] row-cleanup ] unit-test

! Raising a row must preserve every earlier relation in its component.
{ t } [ {
    { ( ..a -- ..b ) ( x -- ) }
    { ( ..b -- ..c ) ( x x -- x ) }
    { ( ..c -- ..a ) ( -- x x ) }
} compatible-rows? ] unit-test

{ t } [ {
    { ( ..c -- ..a ) ( -- x x ) }
    { ( ..b -- ..c ) ( x x -- x ) }
    { ( ..a -- ..b ) ( x -- ) }
} compatible-rows? ] unit-test

{ f } [ {
    { ( ..a -- ..b ) ( x -- ) }
    { ( ..b -- ..c ) ( x x -- x ) }
    { ( ..c -- ..a ) ( -- x ) }
} compatible-rows? ] unit-test

! A monomorphic side anchors its component; it cannot grow with another row.
{ f } [ {
    { ( -- ..a ) ( -- x ) }
    { ( ..a -- ..b ) ( x x -- ) }
} compatible-rows? ] unit-test

{ f } [ {
    { ( ..a -- ..b ) ( x x -- ) }
    { ( -- ..a ) ( -- x ) }
} compatible-rows? ] unit-test

{ t } [ { { ( x x -- x x ) ( -- ) } } compatible-rows? ] unit-test
{ f } [ { { ( x -- x ) ( x x -- x x ) } } compatible-rows? ] unit-test
{ f } [ { { ( ..a -- ..a ) ( -- x ) } } compatible-rows? ] unit-test
{ f } [ { { ( ..a -- * ) ( -- ) } } compatible-rows? ] unit-test
{ t } [ { { ( ..a -- ..b ) ( -- * ) } } compatible-rows? ] unit-test
