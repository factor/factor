! Copyright (C) 2017 Alexander Ilin.

USING: kernel sequences tools.test charts.lines
charts.lines.private ;
IN: charts.lines.tests

{ -2/3 } [ { 1 3 } { -2 5 } calc-line-slope ] unit-test
{ 3 } [ -2/3 1 { 1 3 } calc-y ] unit-test
{ 5 } [ -2/3 -2 { 1 3 } calc-y ] unit-test
{ 3 } [ -2/3 1 { -2 5 } calc-y ] unit-test
{ 5 } [ -2/3 -2 { -2 5 } calc-y ] unit-test
{ 5 } [ -2 { 1 3 } { -2 5 } y-at ] unit-test
{ 3 } [ 1 { 1 3 } { -2 5 } y-at ] unit-test
{ 1 } [ 4 { -2 5 } { 1 3 } y-at ] unit-test
{ 0.0 } [ 5.5 { -2 5 } { 1 3 } y-at ] unit-test
{ 1 } [ -2/3 3 { 1 3 } calc-x ] unit-test
{ -2 } [ -2/3 5 { 1 3 } calc-x ] unit-test
{ 1 } [ -2/3 3 { -2 5 } calc-x ] unit-test
{ -2 } [ -2/3 5 { -2 5 } calc-x ] unit-test

{ 2 3 } [ { 1 2 3 } last2 ] unit-test
{ 1 2 } [ { 1 2 } last2 ] unit-test
[ { 1 } last2 ] must-fail
[ { } last2 ] must-fail

! tight bounds
{
    { { { 0 0 } { 0 1 } { 1 2 } { 1 3 } { 2 5 } } }
} [
    { { 0 0 } { 0 1 } { 1 2 } { 1 3 } { 2 5 } } { 0 5 }
    drawable-chunks [ { } like ] map
] unit-test

! loose bounds
{
    { { { 0 0 } { 0 1 } { 1 2 } { 1 3 } { 2 5 } } }
} [
    { { 0 0 } { 0 1 } { 1 2 } { 1 3 } { 2 5 } } { -1 6 }
    drawable-chunks [ { } like ] map
] unit-test

! only bottom element accepted
{
    { { { 0 0 } } }
} [
    { { 0 0 } { 0 1 } { 1 2 } { 1 3 } { 2 5 } } { -1 0 }
    drawable-chunks [ { } like ] map
] unit-test

! only top element accepted
{
    { { { 2 5 } } }
} [
    { { 0 0 } { 0 1 } { 1 2 } { 1 3 } { 2 5 } } { 5 10 }
    drawable-chunks [ { } like ] map
] unit-test

! top half of the elements accepted
{
    { { { 1 2 } { 1 3 } { 2 5 } } }
} [
    { { 0 0 } { 0 1 } { 1 2 } { 1 3 } { 2 5 } } { 2 10 }
    drawable-chunks [ { } like ] map
] unit-test

! bottom half of the elements accepted
{
    { { { 0 0 } { 0 1 } { 1 2 } } }
} [
    { { 0 0 } { 0 1 } { 1 2 } { 1 3 } { 2 5 } } { -2 2 }
    drawable-chunks [ { } like ] map
] unit-test

! middle section of the elements accepted
{
    { { { 0 1 } { 1 2 } { 1 3 } } }
} [
    { { 0 0 } { 0 1 } { 1 2 } { 1 3 } { 2 5 } } { 1 3 }
    drawable-chunks [ { } like ] map
] unit-test

! two sections, including first but not last
{
    {
        { { 0 0 } { 1 2 } { 2 3 } }
        { { 5 3 } { 6 2 } { 7 0 } }
    }
} [
    { { 0 0 } { 1 2 } { 2 3 } { 3 5 } { 4 5 } { 5 3 } { 6 2 } { 7 0 } { 8 -1 } { 9 -2 } } { 0 3 }
    drawable-chunks [ { } like ] map
] unit-test

! two sections, including last but not first
{
    {
        { { 2 0 } { 3 3 } { 4 3 } }
        { { 7 3 } { 8 2 } { 9 0 } }
    }
} [
    { { 0 -2 } { 1 -1 } { 2 0 } { 3 3 } { 4 3 } { 5 5 } { 6 9 } { 7 3 } { 8 2 } { 9 0 } } { 0 3 }
    drawable-chunks [ { } like ] map
] unit-test

! single-element sequences, same x coord
{
    {
        { { 0 0 } }
        { { 0 3 } }
    }
} [
    { { 0 -2 } { 0 0 } { 0 5 } { 0 3 } { 0 -1 } } { 0 3 }
    drawable-chunks [ { } like ] map
] unit-test

{ { } }
[ { } { } clip-data ] unit-test

{ { } }
[ { { 0 1 } { 0 5 } } { } clip-data ] unit-test

! Adjustment after search is required in both directions.
{
    {
        { 1 3 } { 1 4 } { 1 5 }
        { 2 6 } { 3 7 } { 4 8 }
        { 5 9 } { 5 10 } { 5 11 } { 5 12 }
    }
} [
    { { 1 5 } { 0 14 } }
    {
        { 0 1 } { 0 2 }
        { 1 3 } { 1 4 } { 1 5 }
        { 2 6 } { 3 7 } { 4 8 }
        { 5 9 } { 5 10 } { 5 11 } { 5 12 }
        { 6 13 } { 7 14 }
    } clip-data
] unit-test

! TODO: add tests where after search there is no adjustment necessary, so that extra adjustment would take bad elements. Also, add tests for sequences fully outside the range.
