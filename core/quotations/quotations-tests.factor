USING: combinators kernel math quotations.private sequences
stack-checker stack-checker.errors tools.test words ;
IN: quotations

{ [ 3 ] } [ 3 [ ] curry ] unit-test
{ [ \ + ] } [ \ + [ ] curry ] unit-test
{ [ \ + = ] } [ \ + [ = ] curry ] unit-test

{ [ 1 + 2 + 3 + ] } [
    { 1 2 3 } [ [ + ] curry ] map concat
] unit-test

{ [ 1 2 3 4 ] } [ [ 1 2 ] [ 3 4 ] append ] unit-test
{ [ 1 2 3 ] } [ [ 1 2 ] 3 suffix ] unit-test
{ [ 3 1 2 ] } [ [ 1 2 ] 3 prefix ] unit-test

{ [ "hi" ] } [ "hi" 1quotation ] unit-test

{ 3 } [ 2 1 \ + curry call ] unit-test
{ [ 1 + ] } [ 1 \ + curry >quotation ] unit-test
{ [ + ] } [ \ + >quotation ] unit-test
{ [ + sq ] } [ \ + \ sq compose >quotation ] unit-test
{ 9 } [ 1 2 \ + \ sq compose call ] unit-test
{ 9 } [ 1 2 \ + \ sq compose call( x y -- z ) ] unit-test
{ 4 -2 } [ 2 \ sq \ neg bi ] unit-test
{ 3 } [ 1 2 \ + call ] unit-test
{ 3 } [ 1 2 \ + call( x y -- z ) ] unit-test
{ 2 1 } [ \ + call ] must-infer-as
{ t } [ \ + callable? ] unit-test
{ f } [ \ + sequence? ] unit-test
{ f } [ \ + \ - = ] unit-test
[ 1 2 curry ] must-fail

: no-input-call ( quot: ( -- x ) -- x ) call ; inline
[ [ 1 \ + curry no-input-call ] infer ]
[ unbalanced-branches-error? ] must-fail-with
[ [ \ + \ sq compose no-input-call ] infer ]
[ unbalanced-branches-error? ] must-fail-with

: trouble ( -- arr quot ) { 123 } dup array>quotation ;

{ 999 } [
    ! Call the quotation which compiles it.
    trouble call drop
    ! Change the array used for it.
    999 0 rot set-nth
    trouble nip call
] unit-test

{ [ ] } [ { } compose-all ] unit-test
{ [ 1 + 2 - ] } [ { [ 1 + ] [ 2 - ] } compose-all ] unit-test
