IN: temporary
USING: matrices test ;

[
    M[ [ 0 ] [ 0 ] [ 0 ] ]M
] [
    3 1 <zero-matrix>
] unit-test

[
    M[ [ 1 ] [ 2 ] [ 3 ] ]M
] [
    { 1 2 3 } <col-vector>
] unit-test

[
    M[ [ 1 0 0 ]
       [ 0 1 0 ]
       [ 0 0 1 ] ]M
] [
    3 <identity-matrix>
] unit-test

[
    M[ [ 1 0 4 ]
       [ 0 7 0 ]
       [ 6 0 3 ] ]M
] [
    M[ [ 1 0 0 ]
       [ 0 2 0 ]
       [ 0 0 3 ] ]M
       
    M[ [ 0 0 4 ]
       [ 0 5 0 ]
       [ 6 0 0 ] ]M

    v+
] unit-test

[
    M[ [ 1 0 4 ]
       [ 0 7 0 ]
       [ 6 0 3 ] ]M
] [
    M[ [ 1 0 0 ]
       [ 0 2 0 ]
       [ 0 0 3 ] ]M
       
    M[ [ 0 0 -4 ]
       [ 0 -5 0 ]
       [ -6 0 0 ] ]M

    v-
] unit-test

[
    { 10 20 30 }
] [
    10 { 1 2 3 } v.
] unit-test

[
    { 10 20 30 }
] [
    { 1 2 3 } 10 v.
] unit-test

[
    { 3 4 }
] [
    M[ [ 1 0 ]
       [ 0 1 ] ]M

    { 3 4 }

    v.
] unit-test
