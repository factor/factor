USING: math kernel quotations tools.test sequences ;
IN: quotations.tests

[ [ 3 ] ] [ 3 [ ] curry ] unit-test
[ [ \ + ] ] [ \ + [ ] curry ] unit-test
[ [ \ + = ] ] [ \ + [ = ] curry ] unit-test

[ [ 1 + 2 + 3 + ] ] [
    { 1 2 3 } [ [ + ] curry ] map concat
] unit-test

[ [ 1 2 3 4 ] ] [ [ 1 2 ] [ 3 4 ] append ] unit-test
[ [ 1 2 3 ] ] [ [ 1 2 ] 3 suffix ] unit-test
[ [ 3 1 2 ] ] [ [ 1 2 ] 3 prefix ] unit-test

[ [ "hi" ] ] [ "hi" 1quotation ] unit-test

[ 1 \ + curry ] must-fail
