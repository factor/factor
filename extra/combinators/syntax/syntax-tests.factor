USING: tools.test combinators.syntax math kernel  ;

{ 3 1 } [
    2 3
    *[ 1 + | 2 - ]
] unit-test

{ 6 7 } [
    5
    &[ 1 + | 2 + ]
] unit-test

{ 7 7 } [
    5 2
    [| x | &[ x + | x + ] ] call
] unit-test

{ 3 -1 } [
    1 2
    2 n&[ + | - ]
] unit-test

{ 7 -1 } [
    3 4 1 2
    2 n*[ + | - ]
] unit-test

{ 7 -1 } [
    14 6
    2 @[ 7 - ]
] unit-test

{ 1 2 } [
    0 1 1 1
    2 2 n@[ + ]
] unit-test

{ t } [ 1 2 2 n&&[ drop 1 = | nip 2 = ] ] unit-test

{ t } [ 1 1 n||[ 1 = | even? ] ] unit-test
{ t } [ 2 1 n||[ 1 = | even? ] ] unit-test
{ f } [ 3 1 n||[ 1 = | 3 > ] ] unit-test
