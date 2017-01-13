! Copyright (C) 2017 Alexander Ilin.

USING: tools.test charts.lines charts.lines.private ;
IN: charts.lines.tests

{ -2/3 } [ { 1 3 } { -2 5 } calc-line-slope ] unit-test
{ 3 } [ -2/3 1 { 1 3 } calc-y ] unit-test
{ 5 } [ -2/3 -2 { 1 3 } calc-y ] unit-test
{ 3 } [ -2/3 1 { -2 5 } calc-y ] unit-test
{ 5 } [ -2/3 -2 { -2 5 } calc-y ] unit-test

{ 2 3 } [ { 1 2 3 } last2 ] unit-test
{ 1 2 } [ { 1 2 } last2 ] unit-test
[ { 1 } last2 ] must-fail
[ { } last2 ] must-fail

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
