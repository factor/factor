IN: temporary
USING: kernel matrices test ;

{
    { 1 0 0 }
    { 0 0 1 }
    { 0 1 0 }
} [
    [ 0 ] [ 0 first-col ] unit-test
    [ 2 ] [ 1 first-col ] unit-test
    [ 1 ] [ 2 first-col ] unit-test
] with-matrix drop

[
    {
        { 1 0 2 }
        { 0 0 -3 }
        { 0 1 -6 }
    }
] [
    {
        { 1 0 2 }
        { 2 0 1 }
        { 3 1 0 }
    } [
        0 0 clear-col
    ] with-matrix
] unit-test

[ -2 ] [ 0 { 1 2 3 } { 2 7 8 } clear-scale ] unit-test

[
    {
        { 1 0 2 }
        { 0 0 -3 }
        { 0 1 -6 }
    }
] [
    {
        { 1 0 2 }
        { 2 0 1 }
        { 3 1 0 }
    } [
        0 0 clear-col
    ] with-matrix
] unit-test

[
    {
        { 1 0 0 3 }
        { 0 2 0 4 }
        { 0 0 6 8 }
        { 0 0 0 4 }
    }
] [
    {
        { 1 0 0 3 }
        { 0 0 6 8 }
        { 0 2 0 4 }
        { 0 0 0 4 }
    } [
        0 0 do-row
        2 1 do-row
    ] with-matrix
] unit-test

[
    {
        { 1 0 0 1 }
        { 0 0 6 6 }
        { 0 2 0 2 }
        { 0 0 0 2 }
    }
] [
    {
        { 1 0 0 1 }
        { 2 0 6 8 }
        { 2 2 0 4 }
        { 2 0 0 4 }
    } [
        0 0 do-row
    ] with-matrix
] unit-test

{
    { 0 1 0 1 }
    { 1 0 0 1 }
    { 1 0 0 0 }
    { 1 1 0 1 }
} [
    [ 1 ] [ 0 0 pivot-row ] unit-test
] with-matrix drop

[
    {
        { 1 0 0 0 }
        { 0 1 0 0 }
        { 0 0 1 0 }
        { 0 0 0 1 }
    }
] [
    {
        { 1 0 0 0 }
        { 0 1 0 0 }
        { 0 0 1 0 }
        { 0 0 0 1 }
    } row-reduce
] unit-test

[
    {
        { 1 0 0 0 }
        { 0 1 0 0 }
        { 0 0 1 0 }
        { 0 0 0 1 }
    }
] [
    {
        { 1 0 0 0 }
        { 1 1 0 0 }
        { 1 0 1 0 }
        { 1 0 0 1 }
    } row-reduce
] unit-test

[
    {
        { 1 0 0 0 }
        { 0 1 0 0 }
        { 0 0 1 0 }
        { 0 0 0 1 }
    }
] [
    {
        { 1 0 0 0 }
        { 1 1 0 0 }
        { 1 0 1 0 }
        { 1 1 0 1 }
    } row-reduce
] unit-test

[
    {
        { 1 0 0 0 }
        { 0 1 0 0 }
        { 0 0 1 0 }
        { 0 0 0 1 }
    }
] [
    {
        { 1 0 0 0 }
        { 1 1 0 0 }
        { 1 1 0 1 }
        { 1 0 1 0 }
    } row-reduce
] unit-test

[
    {
        { 1 0 0 0 }
        { 0 1 0 0 }
        { 0 0 0 0 }
        { 0 0 0 0 }
    }
] [
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

[
    {
        { 1 0 0 0 }
        { 0 1 0 0 }
        { 0 0 0 0 }
        { 0 0 0 0 }
    }
] [
    {
        { 0 1 0 0 }
        { 1 0 0 0 }
        { 1 0 0 0 }
        { 1 0 0 0 }
    } row-reduce
] unit-test

[
    {
        { 1 0 0 0 }
        { 0 1 0 0 }
        { 0 0 0 1 }
        { 0 0 0 0 }
    }
] [
    {
        { 1 0 0 0 }
        { 0 1 0 0 }
        { 1 0 0 1 }
        { 1 0 0 1 }
    } row-reduce
] unit-test

[
    {
        { 1 0 0 1 }
        { 0 1 0 1 }
        { 0 0 0 -1 }
        { 0 0 0 0 }
    }
] [
    {
        { 0 1 0 1 }
        { 1 0 0 1 }
        { 1 0 0 0 }
        { 1 1 0 1 }
    } row-reduce
] unit-test

[
    1 3
] [
    {
        { 0 1 0 1 }
        { 1 0 0 1 }
        { 1 0 0 0 }
        { 1 1 0 1 }
    } null/rank
] unit-test
