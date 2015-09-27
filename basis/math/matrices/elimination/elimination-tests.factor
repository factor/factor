IN: math.matrices.elimination.tests
USING: kernel math.matrices math.matrices.elimination
tools.test sequences ;

{
    {
        { 1 0 0 0 }
        { 0 1 0 0 }
        { 0 0 1 0 }
        { 0 0 0 1 }
    }
} [
    {
        { 1 0 0 0 }
        { 0 1 0 0 }
        { 0 0 1 0 }
        { 0 0 0 1 }
    } echelon
] unit-test

{
    {
        { 1 0 0 0 }
        { 0 1 0 0 }
        { 0 0 1 0 }
        { 0 0 0 1 }
    }
} [
    {
        { 1 0 0 0 }
        { 1 1 0 0 }
        { 1 0 1 0 }
        { 1 0 0 1 }
    } echelon
] unit-test

{
    {
        { 1 0 0 0 }
        { 0 1 0 0 }
        { 0 0 1 0 }
        { 0 0 0 1 }
    }
} [
    {
        { 1 0 0 0 }
        { 1 1 0 0 }
        { 1 0 1 0 }
        { 1 1 0 1 }
    } echelon
] unit-test

{
    {
        { 1 0 0 0 }
        { 0 1 0 0 }
        { 0 0 1 0 }
        { 0 0 0 1 }
    }
} [
    {
        { 1 0 0 0 }
        { 1 1 0 0 }
        { 1 1 0 1 }
        { 1 0 1 0 }
    } echelon
] unit-test

{
    {
        { 1 0 0 0 }
        { 0 1 0 0 }
        { 0 0 0 0 }
        { 0 0 0 0 }
    }
} [
    {
        { 0 1 0 0 }
        { 1 0 0 0 }
        { 1 0 0 0 }
        { 1 0 0 0 }
    } [
        [ 1 ] [ 0 0 pivot-row ] unit-test
        1 0 do-row
    ] with-matrix
] unit-test

{
    {
        { 1 0 0 0 }
        { 0 1 0 0 }
        { 0 0 0 0 }
        { 0 0 0 0 }
    }
} [
    {
        { 0 1 0 0 }
        { 1 0 0 0 }
        { 1 0 0 0 }
        { 1 0 0 0 }
    } echelon
] unit-test

{
    {
        { 1 0 0 0 }
        { 0 1 0 0 }
        { 0 0 0 1 }
        { 0 0 0 0 }
    }
} [
    {
        { 1 0 0 0 }
        { 0 1 0 0 }
        { 1 0 0 1 }
        { 1 0 0 1 }
    } echelon
] unit-test

{
    {
        { 1 0 0 1 }
        { 0 1 0 1 }
        { 0 0 0 -1 }
        { 0 0 0 0 }
    }
} [
    {
        { 0 1 0 1 }
        { 1 0 0 1 }
        { 1 0 0 0 }
        { 1 1 0 1 }
    } echelon
] unit-test

{
    2
} [
    {
        { 0 0 }
        { 0 0 }
    } nullspace length
] unit-test

{
    1 3
} [
    {
        { 0 1 0 1 }
        { 1 0 0 1 }
        { 1 0 0 0 }
        { 1 1 0 1 }
    } null/rank
] unit-test

{
    1 3
} [
    {
        { 0 0 0 0 0 1 0 1 }
        { 0 0 0 0 1 0 0 1 }
        { 0 0 0 0 1 0 0 0 }
        { 0 0 0 0 1 1 0 1 }
    } null/rank
] unit-test

{ { { 1 0 -1 } { 0 1 2 } } }
[ { { 1 2 3 } { 4 5 6 } } solution ] unit-test
