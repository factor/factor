USING: compiler.cfg.linear-scan.ranges fry kernel sequences tools.test ;
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
