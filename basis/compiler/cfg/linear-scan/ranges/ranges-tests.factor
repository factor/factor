USING: arrays compiler.cfg.linear-scan.ranges fry kernel sequences
tools.test ;
IN: compiler.cfg.linear-scan.ranges.tests

: combine-ranges ( seq -- ranges )
    V{ } clone [ '[ first2 _ add-range ] each ] keep ;

! extend-ranges?
{ f } [
    10 { } extend-ranges?
] unit-test

! add-range
{
    V{ T{ live-range { from 5 } { to 12 } } }
    V{ T{ live-range { from 5 } { to 12 } } }
} [
    { { 5 10 } { 8 12 } } combine-ranges
    { { 10 12 } { 5 10 } } combine-ranges
] unit-test

! intersect-range
{ f 15 f 10 5 } [
    10 20 <live-range> 30 40 <live-range> intersect-range
    10 20 <live-range> 15 16 <live-range> intersect-range
    T{ live-range f 0 10 } T{ live-range f 20 30 } intersect-range
    T{ live-range f 0 10 } T{ live-range f 10 30 } intersect-range
    T{ live-range f 0 10 } T{ live-range f 5 30 } intersect-range
] unit-test

! intersect-ranges
{ 50 f f f 11 8 f f } [
    {
        T{ live-range f 0 10 }
        T{ live-range f 20 30 }
        T{ live-range f 40 50 }
    }
    {
        T{ live-range f 11 15 }
        T{ live-range f 31 35 }
        T{ live-range f 50 55 }
    }
    intersect-ranges
    {
        T{ live-range f 0 10 }
        T{ live-range f 20 30 }
        T{ live-range f 40 50 }
    }
    {
        T{ live-range f 11 15 }
        T{ live-range f 31 36 }
        T{ live-range f 51 55 }
    }
    intersect-ranges
    { } { T{ live-range f 11 15 } } intersect-ranges
    { T{ live-range f 11 15 } } { } intersect-ranges
    { T{ live-range f 11 15 } }
    { T{ live-range f 10 15 } T{ live-range f 16 18 } }
    intersect-ranges
    { T{ live-range f 4 20 } } { T{ live-range f 8 12 } }
    intersect-ranges
    { T{ live-range f 9 20 } T{ live-range f 3 5 } }
    { T{ live-range f 0 1 } T{ live-range f 7 8 } }
    intersect-ranges
    { T{ live-range f 3 5 } } { T{ live-range f 7 8 } } intersect-ranges
] unit-test

! ranges-cover?
{
    t f f t t
} [
    115 { { 90 120 } { 40 50 } } combine-ranges ranges-cover?
    50 { { 60 70 } { 20 30 } } combine-ranges ranges-cover?
    120 { { 130 140 } { 70 80 } { 50 60 } { 44 48 } { 40 42 } }
    combine-ranges ranges-cover?
    135 { { 130 140 } { 70 80 } { 50 60 } { 44 48 } }
    combine-ranges ranges-cover?
    135 { { 130 140 } { 70 80 } { 50 60 } { 44 48 } { 40 42 } } reverse
    combine-ranges ranges-cover?
] unit-test

! shorten-ranges
{
    V{ T{ live-range { from 8 } { to 12 } } }
    V{ T{ live-range { from 9 } { to 9 } } }
} [
    8 { { 4 12 } } combine-ranges [ shorten-ranges ] keep
    9 { } combine-ranges [ shorten-ranges ] keep
] unit-test

! split range
{
    T{ live-range f 10 15 }
    T{ live-range f 16 20 }
} [
    10 20 <live-range> 15 split-range
] unit-test

! split-ranges
{
    { T{ live-range { from 10 } { to 20 } } }
    { T{ live-range { from 30 } { to 40 } } }
} [
    10 20 <live-range> 30 40 <live-range> 2array 25 split-ranges
] unit-test

{
    { T{ live-range f 0 0 } }
    { T{ live-range f 1 5 } }
} [
    { T{ live-range f 0 5 } } 0 split-ranges
] unit-test

{
    { T{ live-range f 1 10 } T{ live-range f 15 17 } }
    { T{ live-range f 18 20 } }
} [
    {
        T{ live-range f 1 10 }
        T{ live-range f 15 20 }
    } 17 split-ranges
] unit-test

{
    { T{ live-range f 1 10 } }
    { T{ live-range f 15 20 } }
} [
    {
        T{ live-range f 1 10 }
        T{ live-range f 15 20 }
    } 12 split-ranges
] unit-test

{
    { T{ live-range f 1 10 } T{ live-range f 15 16 } }
    { T{ live-range f 17 20 } }
} [
    {
        T{ live-range f 1 10 }
        T{ live-range f 15 20 }
    } 16 split-ranges
] unit-test

{
    { T{ live-range f 1 10 } T{ live-range f 15 15 } }
    { T{ live-range f 16 20 } }
} [
    {
        T{ live-range f 1 10 }
        T{ live-range f 15 20 }
    } 15 split-ranges
] unit-test

[
    { T{ live-range f 1 10 } } 0 split-ranges
] must-fail

! valid-ranges?
{ t f f f } [
    { T{ live-range f 1 10 } T{ live-range f 15 20 } } valid-ranges?
    { T{ live-range f 10 1 } T{ live-range f 15 20 } } valid-ranges?
    { T{ live-range f 1 5 } T{ live-range f 3 10 } } valid-ranges?
    { T{ live-range f 5 1 } } valid-ranges?
] unit-test

! fix-lower-bound
{
    {
        T{ live-range { from 25 } { to 30 } }
        T{ live-range { from 40 } { to 50 } }
    }
    { T{ live-range { from 10 } { to 23 } } }
} [
    25 {
        T{ live-range { from 0 } { to 10 } }
        T{ live-range { from 20 } { to 30 } }
        T{ live-range { from 40 } { to 50 } }
    } fix-lower-bound
    10 { T{ live-range { from 20 } { to 23 } } } fix-lower-bound
] unit-test

! fix-upper-bound
{
    {
        T{ live-range { from 0 } { to 10 } }
        T{ live-range { from 20 } { to 20 } }
    }
} [
    20 {
        T{ live-range { from 0 } { to 10 } }
        T{ live-range { from 20 } { to 30 } }
        T{ live-range { from 40 } { to 50 } }
    } fix-upper-bound
] unit-test

{
    { T{ live-range { from 0 } { to 20 } } }
} [
    20 { T{ live-range { from 0 } { to 40 } } } fix-upper-bound
] unit-test
