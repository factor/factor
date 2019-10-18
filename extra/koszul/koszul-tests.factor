USING: koszul tools.test kernel sequences assocs namespaces ;
IN: koszul.tests

{
    { V{ { } } V{ { 1 } } V{ { 2 3 } { 7 8 } } V{ { 4 5 6 } } }
} [
    { { 1 } { 2 3 } { 4 5 6 } { 7 8 } { } } graded
] unit-test

SYMBOLS: x1 x2 x3 x4 x5 x6 z1 z2 ;

{ H{ { { x1 } 3 } } } [ x1 3 wedge ] unit-test

{ H{ { { x1 } 3 } { { x2 } 4 } } }
[ x1 3 wedge x2 4 wedge alt+ ] unit-test

x1 x2 wedge z1 d=
x3 x4 wedge z2 d=

{ H{ { { x1 x2 z2 } 1 } { { x3 x4 z1 } -1 } } }
[ z1 z2 wedge d ] unit-test

! Unimodular example
boundaries get clear-assoc

SYMBOLS: x y w z ;

x y wedge z d=
y z wedge x d=
z x wedge y d=

{ { 1 0 0 1 } } [ { x y z } graded-betti ] unit-test

! Solvable example
boundaries get clear-assoc

x y wedge y d=

{ { 1 1 0 } } [ { x y } graded-betti ] unit-test

! Nilpotent example
boundaries get clear-assoc

x1 x2 wedge x3 x4 wedge alt+ z d=

{ { 1 4 5 5 4 1 } }
[ { x1 x2 x3 x4 z } graded-betti ] unit-test

{ { { 1 4 5 0 0 } { 0 0 5 4 1 } } }
[ { x1 x2 x3 x4 } { z } bigraded-betti ] unit-test

! Free 2-step on 4 generators
boundaries get clear-assoc

SYMBOLS: e12 e13 e14 e23 e24 e34 ;

x1 x2 wedge e12 d=
x1 x3 wedge e13 d=
x1 x4 wedge e14 d=
x2 x3 wedge e23 d=
x2 x4 wedge e24 d=
x3 x4 wedge e34 d=

{ { 1 4 20 56 84 90 84 56 20 4 1 } }
[ { x1 x2 x3 x4 e12 e13 e14 e23 e24 e34 } graded-betti ]
unit-test

! Make sure this works
{ } [ e12 d alt. ] unit-test

{ } [
    { x1 x2 x3 x4 x5 x6 } { w z }
    bigraded-laplacian-kernel bigraded-basis.
] unit-test
