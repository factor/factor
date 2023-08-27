! Copyright (C) 2017 Alexander Ilin.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel math math.ratios sequences tools.test
ui.gadgets.charts.lines ui.gadgets.charts.lines.private
ui.gadgets.charts.utils ;

{ -2/3 } [ { 1 3 } { -2 5 } calc-line-slope ] unit-test
[ { 5 0 } { 5 5 } calc-line-slope ] [ division-by-zero? ] must-fail-with
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

! 2-point-chunk upwards
{
    { { -3 -3 } { 3 3 } }
} [
    { { -6 0 } { -5 -5 } } { { 5 5 } { 6 0 } }
    -3 3 2-point-chunk
] unit-test

! 2-point-chunk downwards
{
    { { -3 3 } { 3 -3 } }
} [
    { { -6 0 } { -5 5 } } { { 5 -5 } { 6 0 } }
    -3 3 2-point-chunk
] unit-test

! 2-point-chunk: same x coord
{
    { { -5 -3 } { -5 3 } }
} [
    { { -6 0 } { -5 -5 } } { { -5 5 } { 6 0 } }
    -3 3 2-point-chunk
] unit-test

! fix-left-chunk: y coord = top limit
{
    { { -6 0 } { -3 3 } }
} [
    { { -6 0 } { -3 3 } } { { 5 5 } { 6 6 } }
    -3 3 fix-left-chunk
] unit-test

! fix-left-chunk: y coord = bottom limit
{
    { { -6 0 } { -3 -3 } }
} [
    { { -6 0 } { -3 -3 } } { { 5 -5 } { 6 -6 } }
    -3 3 fix-left-chunk
] unit-test

! fix-left-chunk: going upwards
{
    { { -6 0 } { 2 2 } { 3 3 } }
} [
    { { -6 0 } { 2 2 } } { { 5 5 } { 6 6 } }
    -3 3 fix-left-chunk
] unit-test

! fix-left-chunk: going downwards
{
    { { -6 0 } { -2 -2 } { -1 -3 } }
} [
    { { -6 0 } { -2 -2 } } { { 0 -4 } { 6 -6 } }
    -3 3 fix-left-chunk
] unit-test

! TODO: add more tests for the recently discovered bugs in fix-left-chunk and fix-right-chunk

! fix-right-chunk: y coord = top limit
{
    { { 5 3 } { 6 0 } }
} [
    { { -6 6 } { -3 4 } } { { 5 3 } { 6 0 } }
    -3 3 fix-right-chunk
] unit-test

! fix-right-chunk: y coord = bottom limit
{
    { { 5 -3 } { 6 0 } }
} [
    { { -6 -6 } { -3 -4 } } { { 5 -3 } { 6 0 } }
    -3 3 fix-right-chunk
] unit-test

! fix-right-chunk: going upwards
{
    { { -3 -3 } { -2 -2 } { 6 0 } }
} [
    { { -6 -6 } { -4 -4 } } { { -2 -2 } { 6 0 } }
    -3 3 fix-right-chunk
] unit-test

! fix-right-chunk: going downwards
{
    { { -3 3 } { -2 2 } { 6 0 } }
} [
    { { -6 6 } { -4 4 } } { { -2 2 } { 6 0 } }
    -3 3 fix-right-chunk
] unit-test

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
        { { 0 0 } { 0 3 } }
        { { 0 3 } { 0 0 } }
    }
} [
    { { 0 -2 } { 0 0 } { 0 5 } { 0 3 } { 0 -1 } } { 0 3 }
    drawable-chunks [ { } like ] map
] unit-test

! single point sticks out to within the limits from below
{
    {
        { { 1 1 } { 2 2 } { 3 1 } }
    }
} [
    { { 0 0 } { 2 2 } { 4 0 } } { 1 5 }
    drawable-chunks [ { } like ] map
] unit-test

! single point sticks out to within the limits from above
{
    {
        { { 1 3 } { 2 2 } { 3 3 } }
    }
} [
    { { 0 4 } { 2 2 } { 4 4 } } { 1 3 }
    drawable-chunks [ { } like ] map
] unit-test

{
    { { { 0 300 } { 1 200 } { 2 150 } { 3 100 } { 4 0 } } }
} [
    { { { 0 0 } { 1 100 } { 2 150 } { 3 200 } { 4 300 } } }
    { 0 300 } flip-y-axis
] unit-test

{
    { 0 30 60 90 120 150 180 210 240 270 300 }
} [
    11 <iota> [ 10 + ] map [ 300 swap 20 10 scale ] map
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

! no points within the viewport, complete calculation
{
    { { 1 1 } { 4 4 } }
} [
    { { 1 4 } { 1 4 } }
    { { 0 0 } { 5 5 } } clip-data
] unit-test

! no points within the viewport, complete calculation
{
    { { 1 4 } { 4 1 } }
} [
    { { 1 4 } { 1 4 } }
    { { 0 5 } { 5 0 } } clip-data
] unit-test

! no points within the viewport, complete calculation
{
    { { 1 3 } { 4 3 } }
} [
    { { 1 4 } { 1 4 } }
    { { 0 3 } { 5 3 } } clip-data
] unit-test

! all data are to the left of viewport
{
    { }
} [
    { { 1 4 } { 1 4 } }
    { { -1 0 } { 0 1 } { 0.5 1 } } clip-data
] unit-test

! all data are to the right of viewport
{
    { }
} [
    { { 1 4 } { 1 4 } }
    { { 4.5 0 } { 5 1 } { 6 1 } } clip-data
] unit-test

! just a little off the top
{ t } [
    { 0 99 }
    { { 0 100 } { 100 0 } { 100 50 } { 150 50 } { 200 100 } }
    y-in-bounds?
] unit-test

! TODO: add tests where after search there is no adjustment necessary, so that extra adjustment would take bad elements.
