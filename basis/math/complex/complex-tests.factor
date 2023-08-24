USING: accessors eval kernel math math.complex math.constants
math.functions math.order namespaces prettyprint
prettyprint.config tools.test ;

[ 1 C{ 0 1 } rect> ] must-fail
[ C{ 0 1 } 1 rect> ] must-fail

{ f } [ C{ 5 12.5 } 5 = ] unit-test
{ f } [ C{ 5 12.5 } 5 number= ] unit-test

{ f } [ C{ 1.0 2.0 } C{ 1 2 } = ] unit-test
{ t } [ C{ 1.0 2.0 } C{ 1 2 } number= ] unit-test

{ f } [ C{ 1.0 2.3 } C{ 1 2 } = ] unit-test
{ f } [ C{ 1.0 2.3 } C{ 1 2 } number= ] unit-test

{ C{ 2 5 } } [ 2 5  rect> ] unit-test
{ 2 } [ 2 0  rect> ] unit-test
{ C{ 2 0.0 } } [ 2 0.0  rect> ] unit-test
{ 2 5 } [ C{ 2 5 }  >rect ] unit-test
{ C{ 1/2 1 } } [ 1/2 C{ 0 1 }  + ] unit-test
{ C{ 1/2 1 } } [ C{ 0 1 } 1/2  + ] unit-test
{ t } [ C{ 11 64 } C{ 11 64 }  = ] unit-test
{ C{ 2 1 } } [ 2 C{ 0 1 }  + ] unit-test
{ C{ 2 1 } } [ C{ 0 1 } 2  + ] unit-test
{ C{ 5 4 } } [ C{ 2 2 } C{ 3 2 }  + ] unit-test
{ 5 } [ C{ 2 2 } C{ 3 -2 }  + ] unit-test
{ C{ 1.0 1 } } [ 1.0 C{ 0 1 }  + ] unit-test

{ C{ 1/2 -1 } } [ 1/2 C{ 0 1 }  - ] unit-test
{ C{ -1/2 1 } } [ C{ 0 1 } 1/2  - ] unit-test
{ C{ 1/3 1/4 } } [ 1 3 / 1 2 / i* + 1 4 / i*  - ] unit-test
{ C{ -1/3 -1/4 } } [ 1 4 / i* 1 3 / 1 2 / i* +  - ] unit-test
{ C{ 1/5 1/4 } } [ C{ 3/5 1/2 } C{ 2/5 1/4 }  - ] unit-test
{ 4 } [ C{ 5 10/3 } C{ 1 10/3 }  - ] unit-test
{ C{ 1.0 -1 } } [ 1.0 C{ 0 1 }  - ] unit-test

{ C{ 0 1 } } [ C{ 0 1 } 1  * ] unit-test
{ C{ 0 1 } } [ 1 C{ 0 1 }  * ] unit-test
{ C{ 0.0 1.0 } } [ 1.0 C{ 0 1 }  * ] unit-test
{ -1 } [ C{ 0 1 } C{ 0 1 }  * ] unit-test
{ C{ 0 1 } } [ 1 C{ 0 1 }  * ] unit-test
{ C{ 0 1 } } [ C{ 0 1 } 1  * ] unit-test
{ C{ 0 1/2 } } [ 1/2 C{ 0 1 }  * ] unit-test
{ C{ 0 1/2 } } [ C{ 0 1 } 1/2  * ] unit-test
{ 2 } [ C{ 1 1 } C{ 1 -1 }  * ] unit-test
{ 1 } [ C{ 0 1 } C{ 0 -1 }  * ] unit-test

{ -1 } [ C{ 0 1 } C{ 0 -1 }  / ] unit-test
{ C{ 0 1 } } [ 1 C{ 0 -1 }  / ] unit-test
{ t } [ C{ 12 13 } C{ 13 14 } / C{ 13 14 } * C{ 12 13 }  = ] unit-test

{ C{ -3 4 } } [ C{ 3 -4 }  neg ] unit-test

{ 5.0 } [ C{ 3 4 } abs ] unit-test
{ 5.0 } [ -5.0 abs ] unit-test

! Make sure arguments are sane
{ 0.0 } [ 0 arg ] unit-test
{ 0.0 } [ 1 arg ] unit-test
{ t } [ -1 arg 3.14 3.15 between? ] unit-test
{ t } [ C{ 0 1 } arg 1.57 1.58 between? ] unit-test
{ t } [ C{ 0 -1 } arg -1.58 -1.57 between? ] unit-test

{ 1.0 0.0 } [ 1 >polar ] unit-test
{ 1.0 } [ -1 >polar drop ] unit-test
{ t } [ -1 >polar nip 3.14 3.15 between? ] unit-test

! I broke something
[ C{ 1 4 } tanh ] must-not-fail
[ C{ 1 4 } tan ] must-not-fail
[ C{ 1 4 } coth ] must-not-fail
[ C{ 1 4 } cot ] must-not-fail

{ t } [ 0.0 pi rect> e^ C{ -1 0 } 1.0e-7 ~ ] unit-test
{ t } [ 0 pi rect> e^ C{ -1 0 } 1.0e-7 ~ ] unit-test

10 number-base [
    [ "C{ 1/2 2/3 }" ] [ C{ 1/2 2/3 } unparse ] unit-test
] with-variable

[ "C{ 1 2 3 }" eval( -- obj ) ]
[ error>> T{ malformed-complex f V{ 1 2 3 } } = ] must-fail-with
