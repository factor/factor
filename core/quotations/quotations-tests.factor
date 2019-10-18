USING: math kernel quotations tools.test sequences ;
IN: temporary

[ [ 3 ] ] [ 3 f curry ] unit-test
[ [ \ + ] ] [ \ + f curry ] unit-test
[ [ \ + = ] ] [ \ + [ = ] curry ] unit-test

[ [ 1 + 2 + 3 + ] ] [
    { 1 2 3 } [ [ + ] curry ] map concat
] unit-test
