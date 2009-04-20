IN: math.matrices.tests
USING: math.matrices math.vectors tools.test math ;

[
    { { 0 } { 0 } { 0 } }
] [
    3 1 zero-matrix
] unit-test

[
    { { 1 0 0 }
       { 0 1 0 }
       { 0 0 1 } }
] [
    3 identity-matrix
] unit-test

[
    { { 1 0 4 }
       { 0 7 0 }
       { 6 0 3 } }
] [
    { { 1 0 0 }
       { 0 2 0 }
       { 0 0 3 } }
       
    { { 0 0 4 }
       { 0 5 0 }
       { 6 0 0 } }

    m+
] unit-test

[
    { { 1 0 4 }
       { 0 7 0 }
       { 6 0 3 } }
] [
    { { 1 0 0 }
       { 0 2 0 }
       { 0 0 3 } }
       
    { { 0 0 -4 }
       { 0 -5 0 }
       { -6 0 0 } }

    m-
] unit-test

[
    { 10 20 30 }
] [
    10 { 1 2 3 } n*v
] unit-test

[
    { 3 4 }
] [
    { { 1 0 }
       { 0 1 } }

    { 3 4 }

    m.v
] unit-test

[
    { 4 3 }
] [
    { { 0 1 }
       { 1 0 } }

    { 3 4 }

    m.v
] unit-test

[
    { { 6 } }
] [
    { { 3 } } { { 2 } } m.
] unit-test

[
    { { 11 } }
] [
    { { 1 3 } } { { 5 } { 2 } } m.
] unit-test

[
    { { 28 } }
] [
    { { 2 4 6 } }

    { { 1 }
       { 2 }
       { 3 } }
    
    m.
] unit-test

[ { 0 0 -1 } ] [ { 1 0 0 } { 0 1 0 } cross ] unit-test
[ { 1 0 0 } ] [ { 0 1 0 } { 0 0 1 } cross ] unit-test
[ { 0 1 0 } ] [ { 0 0 1 } { 1 0 0 } cross ] unit-test

[ { 1 0 0 } ] [ { 1 1 0 } { 1 0 0 } proj ] unit-test

[ { { { 1 "a" } { 1 "b" } } { { 2 "a" } { 2 "b" } } } ]
[ { 1 2 } { "a" "b" } cross-zip ] unit-test