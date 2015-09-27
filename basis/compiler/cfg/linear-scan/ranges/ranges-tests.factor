USING: arrays compiler.cfg.linear-scan.ranges fry kernel sequences
tools.test ;
IN: compiler.cfg.linear-scan.ranges.tests

! add-new-range
{
    V{ { 10 20 } }
} [
    10 20 V{ } [ add-new-range ] keep
] unit-test

! extend-last?
{ f } [
    10 { } extend-last?
] unit-test

! add-range
{
    V{ { 3 10 } }
    V{ { 5 12 } }
    V{ { 5 12 } }
} [
    3 9 V{ { 5 10 } } [ add-range ] keep
    5 10 V{ { 10 12 } } [ add-range ] keep
    5 9 V{ { 10 12 } } [ add-range ] keep
] unit-test

! intersect-range
{ f 15 10 5 } [
    { 10 20 } { 30 40 } intersect-range
    { 10 20 } { 15 16 } intersect-range
    { 0 10 } { 10 30 } intersect-range
    { 0 10 } { 5 30 } intersect-range
] unit-test

! intersect-ranges
{ 50 f f f 11 8 f f } [
    { { 0 10 } { 20 30 } { 40 50 } }
    { { 11 15 } { 31 35 } { 50 55 } } intersect-ranges
    { { 0 10 } { 20 30 } { 40 50 } }
    { { 11 15 } { 31 36 } { 51 55 } } intersect-ranges
    { } { { 11 15 } } intersect-ranges
    { { 11 15 } } { } intersect-ranges
    { { 11 15 } } { { 10 15 } { 16 18 } } intersect-ranges

    { { 4 20 } } { { 8 12 } } intersect-ranges
    { { 9 20 } { 3 5 } } { { 0 1 } { 7 8 } } intersect-ranges
    { { 3 5 } } { { 7 8 } } intersect-ranges
] unit-test

! ranges-cover?
{
    t f f t t
} [
    115 { { 90 120 } { 40 50 } } ranges-cover?
    50 { { 60 70 } { 20 30 } } ranges-cover?
    120 { { 130 140 } { 70 80 } { 50 60 } { 44 48 } { 40 42 } }
    ranges-cover?
    135 { { 130 140 } { 70 80 } { 50 60 } { 44 48 } }
    ranges-cover?
    135 { { 130 140 } { 70 80 } { 50 60 } { 44 48 } { 40 42 } } reverse
    ranges-cover?
] unit-test

! shorten-ranges
{
    V{ { 8 12 } }
    V{ { 9 9 } }
} [
    8 V{ { 4 12 } } [ shorten-ranges ] keep
    9 V{ } [ shorten-ranges ] keep
] unit-test

! split range
{
    { 10 15 } { 16 20 }
} [
    { 10 20 } 15 split-range
] unit-test

! split-ranges
{ { { 10 20 } } { { 30 40 } } }
[ { { 10 20 } { 30 40 } } 25 split-ranges ] unit-test

{ { { 0 0 } } { { 1 5 } } }
[ { { 0 5 } } 0 split-ranges ] unit-test

{
    { { 1 10 } { 15 17 } }
    { { 18 20 } }
} [
    { { 1 10 } { 15 20 } } 17 split-ranges
] unit-test

{
    { { 1 10 } } { { 15 20 } }
} [
    { { 1 10 } { 15 20 } } 12 split-ranges
] unit-test

{
    { { 1 10 } { 15 16 } }
    { { 17 20 } }
} [
    { { 1 10 } { 15 20 } } 16 split-ranges
] unit-test

{
    { { 1 10 } { 15 15 } }
    { { 16 20 } }
} [
    { { 1 10 } { 15 20 } } 15 split-ranges
] unit-test

[
    { { 1 10 } } 0 split-ranges
] must-fail

! valid-ranges?
{ t f f f } [
    { { 1 10 } { 15 20 } } valid-ranges?
    { { 10 1 } { 15 20 } } valid-ranges?
    { { 1 5 } { 3 10 } } valid-ranges?
    { { 5 1 } } valid-ranges?
] unit-test

! fix-lower-bound
{
    { { 25 30 } { 40 50 } }
    { { 10 23 } }
    { { 366 366 } }
} [
    25 { { 0 10 } { 20 30 } { 40 50 } } fix-lower-bound
    10 { { 20 23 } } fix-lower-bound
    366 { { 355 356 } { 357 366 } } fix-lower-bound
] unit-test

! fix-upper-bound
{
    { { 0 10 } { 20 20 } }
    { { 0 20 } }
    { { 0 10 } { 20 23 } }
} [
    20 { { 0 10 } { 20 30 } { 40 50 } } fix-upper-bound
    20 { { 0 40 } } fix-upper-bound
    23 { { 0 10 } { 20 30 } { 40 50 } } fix-upper-bound
] unit-test

! ranges-endpoints
{ 0 40 } [
    { { 0 10 } { 30 40 } } ranges-endpoints
] unit-test
