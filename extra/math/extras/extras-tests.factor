! Copyright (C) 2012 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: arrays math math.extras math.ranges sequences tools.test ;

IN: math.extras.test

{ -1 } [ -1 7 jacobi ] unit-test
{ 0 } [ 3 3 jacobi ] unit-test
{ -1 } [ 127 703 jacobi ] unit-test
{ 1 } [ -4 197 jacobi ] unit-test

{ { 2 3 4 5 6 7 8 9 } } [ 10 [1,b] 3 moving-average ] unit-test
{ { 1+1/2 2+1/2 3+1/2 4+1/2 5+1/2 6+1/2 7+1/2 8+1/2 9+1/2 } }
[ 10 [1,b] 2 moving-average ] unit-test

{ { 1 1+1/2 2+1/4 3+1/8 4+1/16 5+1/32 } }
[ 6 [1,b] 1/2 exponential-moving-average ] unit-test
{ { 1 3 3 5 5 7 7 9 9 11 } }
[ 10 [1,b] 2 exponential-moving-average ] unit-test

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
    { -10 10 2 2.5 3 } [ { 1 2 3 4 5 } search-sorted ] map
] unit-test

{
    { 1 2 3 4 }
    { 0 1 0 0 2 3 }
} [ { 1 2 1 1 3 4 } unique-indices ] unit-test

{ { 1 8+4/5 16+3/5 24+2/5 32+1/5 } } [ 1 40 5 linspace[a,b) >array ] unit-test
{ { 1 10+3/4 20+1/2 30+1/4 40 } } [ 1 40 5 linspace[a,b] >array ] unit-test
