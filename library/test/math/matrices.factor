IN: temporary
USING: kernel lists math matrices namespaces sequences test
vectors ;

[ [ { 1 4 } { 2 5 } { 3 6 } ] ]
[ M{ { 1 4 } { 2 5 } { 3 6 } }M row-list ] unit-test

[
    M{ { 0 } { 0 } { 0 } }M
] [
    3 1 <zero-matrix>
] unit-test

[
    M{ { 1 } { 2 } { 3 } }M
] [
    { 1 2 3 } <col-matrix>
] unit-test

[
    M{ { 1 0 0 }
       { 0 1 0 }
       { 0 0 1 } }M
] [
    3 <identity-matrix>
] unit-test

[
    M{ { 1 0 4 }
       { 0 7 0 }
       { 6 0 3 } }M
] [
    M{ { 1 0 0 }
       { 0 2 0 }
       { 0 0 3 } }M
       
    M{ { 0 0 4 }
       { 0 5 0 }
       { 6 0 0 } }M

    m+
] unit-test

[
    M{ { 1 0 4 }
       { 0 7 0 }
       { 6 0 3 } }M
] [
    M{ { 1 0 0 }
       { 0 2 0 }
       { 0 0 3 } }M
       
    M{ { 0 0 -4 }
       { 0 -5 0 }
       { -6 0 0 } }M

    m-
] unit-test

[
    { 10 20 30 }
] [
    10 { 1 2 3 } n*v
] unit-test

[
    M{ { 6 } }M
] [
    M{ { 3 } }M M{ { 2 } }M m.
] unit-test

[
    M{ { 11 } }M
] [
    M{ { 1 3 } }M M{ { 5 } { 2 } }M m.
] unit-test

[
    [ [[ 0 0 ]] [[ 1 0 ]] ]
] [
    [ 2 1 [ 2dup cons , ] 2repeat ] make-list
] unit-test

[
    { 3 4 }
] [
    M{ { 1 0 }
       { 0 1 } }M

    { 3 4 }

    m.v
] unit-test

[
    { 4 3 }
] [
    M{ { 0 1 }
       { 1 0 } }M

    { 3 4 }

    m.v
] unit-test

[ { 0 0 1 } ] [ { 1 0 0 } { 0 1 0 } cross ] unit-test
[ { 1 0 0 } ] [ { 0 1 0 } { 0 0 1 } cross ] unit-test
[ { 0 1 0 } ] [ { 0 0 1 } { 1 0 0 } cross ] unit-test

[ M{ { 1 2 } { 3 4 } { 5 6 } }M ]
[ M{ { 1 2 } { 3 4 } { 5 6 } }M transpose transpose ]
unit-test

[ M{ { 1 3 5 } { 2 4 6 } }M ]
[ M{ { 1 3 5 } { 2 4 6 } }M transpose transpose ]
unit-test

[ M{ { 1 3 5 } { 2 4 6 } }M ]
[ M{ { 1 2 } { 3 4 } { 5 6 } }M transpose ]
unit-test

[
    M{ { 28 } }M
] [
    M{ { 2 4 6 } }M

    M{ { 1 }
       { 2 }
       { 3 } }M
    
    m.
] unit-test

[
    { { 7 } { 4 8 } { 1 5 9 } { 2 6 } { 3 } }
] [
    M{ { 1 2 3 } { 4 5 6 } { 7 8 9 } }M
    5 [ 2 - swap <diagonal> >vector ] map-with
] unit-test

[ { t t t } ]
[ { 1 2 3 } { -1 -2 -3 } { 4 5 6 } vbetween? ]
unit-test

[ { t f t } ]
[ { 1 10 3 } { -1 -2 -3 } { 4 5 6 } vbetween? ]
unit-test
