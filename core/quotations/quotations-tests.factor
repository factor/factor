USING: math kernel quotations tools.test sequences ;
IN: temporary

[ [ 3 ] ] [ 3 f curry ] unit-test
[ [ \ + ] ] [ \ + f curry ] unit-test
[ [ \ + = ] ] [ \ + [ = ] curry ] unit-test

[ [ 1 + 2 + 3 + ] ] [
    { 1 2 3 } [ [ + ] curry ] map concat
] unit-test

[ [ 1 2 3 4 ] ] [ [ 1 2 ] [ 3 4 ] append ] unit-test
[ [ 1 2 3 ] ] [ [ 1 2 ] 3 add ] unit-test
[ [ 3 1 2 ] ] [ [ 1 2 ] 3 add* ] unit-test

[ [ "hi" ] ] [ "hi" 1quotation ] unit-test
