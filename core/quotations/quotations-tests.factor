USING: kernel math quotations.private sequences tools.test ;
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

[ 1 \ + curry ] must-fail

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
