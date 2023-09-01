! Copyright (C) 2012 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: arrays kernel math math.extras ranges sequences
tools.test ;

{ 7 } [ 4 2 stirling ] unit-test
{ 90 } [ 6 3 stirling ] unit-test

{ { 1 -1/2 1/6 0 -1/30 0 1/42 0 -1/30 0 } }
[ 10 <iota> [ bernoulli ] map ] unit-test

{ -1 } [ -1 7 jacobi ] unit-test
{ 0 } [ 3 3 jacobi ] unit-test
{ -1 } [ 127 703 jacobi ] unit-test
{ 1 } [ -4 197 jacobi ] unit-test

{ { 2 3 4 5 6 7 8 9 } } [ 10 [1..b] 3 moving-average ] unit-test
{ { 1+1/2 2+1/2 3+1/2 4+1/2 5+1/2 6+1/2 7+1/2 8+1/2 9+1/2 } }
[ 10 [1..b] 2 moving-average ] unit-test

{ { 1 1+1/2 2+1/4 3+1/8 4+1/16 5+1/32 } }
[ 6 [1..b] 1/2 exponential-moving-average ] unit-test
{ { 1 3 3 5 5 7 7 9 9 11 } }
[ 10 [1..b] 2 exponential-moving-average ] unit-test

{ { 2 5 5 4 3 } } [ { 1 2 5 6 1 4 3 } 3 moving-median ] unit-test

{ { 2 1 1 2 1 1 } } [ { 1 1 2 3 5 8 13 } 2 [ odd? ] moving-count ] unit-test

{ { } } [ { 0 0 } nonzero ] unit-test
{ { 1 2 3 } } [ { 0 1 0 2 0 3 0 } nonzero ] unit-test

{ { } } [ 0 bartlett ] unit-test
{ { 1 } } [ 1 bartlett ] unit-test
{ { 0 0 } } [ 2 bartlett ] unit-test
{ { 0 1 0 } } [ 3 bartlett ] unit-test
{ { 0 2/3 2/3 0 } } [ 4 bartlett ] unit-test
{ { 0 1/2 1 1/2 0 } } [ 5 bartlett ] unit-test
{ { 0 2/5 4/5 4/5 2/5 0 } } [ 6 bartlett ] unit-test

{ 2819/3914 } [
    {
        998,000
        20,000
        17,500
        70,000
        23,500
        45,200
    } gini
] unit-test

{ 8457/9785 } [
    {
        998,000
        20,000
        17,500
        70,000
        23,500
        45,200
    } concentration-coefficient
] unit-test

{ 0 } [ { 1 } gini ] unit-test
{ 0 } [ { 1 1 1 1 1 1 } gini ] unit-test
{ 0 } [ { 10 10 10 10 } gini ] unit-test
{ 0 } [ { } gini ] unit-test

{ 0 } [ { 1 } concentration-coefficient ] unit-test
{ 0 } [ { 1 1 1 1 1 1 } concentration-coefficient ] unit-test
{ 0 } [ { 10 10 10 10 } concentration-coefficient ] unit-test
{ 0 } [ { } concentration-coefficient ] unit-test

{ 57/200 } [ { 80 60 10 20 30 } herfindahl ] unit-test
{ 17/160 } [ { 80 60 10 20 30 } normalized-herfindahl ] unit-test

{ { 0 5 1 2 2 } } [
    { -10 10 2 2.5 3 } { 1 2 3 4 5 } digitize]
] unit-test

{ { 0 5 2 2 3 } } [
    { -10 10 2 2.5 3 } { 1 2 3 4 5 } digitize)
] unit-test

{
    { 1 2 3 4 }
    { 0 1 0 0 2 3 }
} [ { 1 2 1 1 3 4 } unique-indices ] unit-test

{ { 1 8+4/5 16+3/5 24+2/5 32+1/5 } } [ 1 40 5 linspace[a..b) >array ] unit-test
{ { 1 10+3/4 20+1/2 30+1/4 40 } } [ 1 40 5 linspace[a..b] >array ] unit-test

{ f } [ { } majority ] unit-test
{ 1 } [ { 1 } majority ] unit-test
{ f } [ { 1 2 } majority ] unit-test
{ 1 } [ { 1 1 2 } majority ] unit-test
{ f } [ { 1 1 2 2 } majority ] unit-test
{ 2 } [ { 1 1 2 2 2 } majority ] unit-test
{ 3 } [ { 1 2 3 1 2 3 1 2 3 3 } majority ] unit-test
{ CHAR: C } [ "AAACCBBCCCBCC" majority ] unit-test

{ 0.0 } [ 0.0 2 round-to-decimal ] unit-test
{ 1.0 } [ 1.0 2 round-to-decimal ] unit-test
{ 1.23 } [ 1.2349 2 round-to-decimal ] unit-test
{ 1.24 } [ 1.2350 2 round-to-decimal ] unit-test
{ 1.24 } [ 1.2351 2 round-to-decimal ] unit-test
{ -1.23 } [ -1.2349 2 round-to-decimal ] unit-test
{ -1.24 } [ -1.2350 2 round-to-decimal ] unit-test
{ -1.24 } [ -1.2351 2 round-to-decimal ] unit-test
{
    {
        0.0 0.0 10000.0 12000.0 12300.0 12350.0 12346.0 12345.7
        12345.68 12345.679 12345.6789 12345.6789 12345.678901
        12345.6789012 12345.67890123 12345.678901235
    }
} [ 12345.67890123456 -6 9 [a..b] [ round-to-decimal ] with map ] unit-test

{ 0 } [ 0 5 round-to-step ] unit-test
{ 0 } [ 1 5 round-to-step ] unit-test
{ 5 } [ 3 5 round-to-step ] unit-test
{ 10 } [ 12 5 round-to-step ] unit-test
{ 15 } [ 13 5 round-to-step ] unit-test

{ 0 } [ 0 round-away-from-zero ] unit-test
{ -1.0 } [ -0.1 round-away-from-zero ] unit-test
{ 1.0 } [ 0.1 round-away-from-zero ] unit-test
{ -2.0 } [ -1.9 round-away-from-zero ] unit-test
{ 2.0 } [ 1.9 round-away-from-zero ] unit-test

{ { 0 1 2 3 0 0 1 } } [ { 1 2 3 3 2 1 2 } [ <= ] monotonic-count ] unit-test
{ 4 } [ { 1 2 3 1 2 3 4 5 } [ < ] max-monotonic-count ] unit-test

{ 4.0 } [ { 1e-30 1 3 -1e-30 } sum-floats ] unit-test
{ 1.0000000000000002e16 } [ { 1e-16 1 1e16 } sum-floats ] unit-test

{
    {
        1 -1 -1 0 -1 1 -1 0 0 1 -1 0 -1 1 1
        0 -1 0 -1 0 1 1 -1 0 0 1 0 0 -1 -1
    }
} [
    30 [1..b] [ mobius ] map
] unit-test

{ 1/5 } [ 3/5 1 kelly ] unit-test
{ 0 } [ 1/2 1 kelly ] unit-test
{ -1/5 } [ 2/5 1 kelly ] unit-test

[ -1 integer-sqrt ] must-fail
{ 0 } [ 0 integer-sqrt ] unit-test
{ 3 } [ 12 integer-sqrt ] unit-test
{ 4 } [ 16 integer-sqrt ] unit-test
{ 44 } [ 2019 integer-sqrt ] unit-test

{ 1 } [ 11 13 stein ] unit-test
{ 2 } [ 14 52 stein ] unit-test
{ 7 } [ 14 7 stein ] unit-test
