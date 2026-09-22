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

! Nullspace vectors must have zero pivot coordinates before scaling.
{ { { -2 1 } } } [ { { 1 2 } } nullspace ] unit-test

{ { } } [ 3 <identity-matrix> nullspace ] unit-test

{ 2 { { 0 0 } { 0 0 } } } [
    { { 1 2 3 } { 2 4 6 } }
    dup clone nullspace [ [ mdotv ] with map ] keep length swap
] unit-test

{ { { 1 0 0 } { 0 -3/2 1 } } } [
    { { 0 2 3 } } nullspace
] unit-test

{ { } } [ { } echelon ] unit-test
{ { } } [ { } nullspace ] unit-test
{ { } } [ { } solution ] unit-test
{ 0 0 } [ { } null/rank ] unit-test
