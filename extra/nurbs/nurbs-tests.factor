! Copyright (C) 2009 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: literals math math.functions math.vectors namespaces
nurbs tools.test ;
IN: nurbs.tests

SYMBOL: test-nurbs

CONSTANT:  √2/2 $[ 0.5 sqrt     ]
CONSTANT: -√2/2 $[ 0.5 sqrt neg ]

! unit circle as NURBS
3 {
    { 1.0 0.0 1.0 }
    ${ √2/2 √2/2 √2/2 }
    { 0.0 1.0 1.0 }
    ${ -√2/2 √2/2 √2/2 }
    { -1.0 0.0 1.0 }
    ${ -√2/2 -√2/2 √2/2 }
    { 0.0 -1.0 1.0 }
    ${ √2/2 -√2/2 √2/2 }
    { 1.0 0.0 1.0 }
} { 0.0 0.0 0.0 0.25 0.25 0.5 0.5 0.75 0.75 1.0 1.0 1.0 } <nurbs-curve> test-nurbs set

{ t } [ test-nurbs get 0.0   eval-nurbs {   1.0   0.0 } 0.00001 v~ ] unit-test
{ t } [ test-nurbs get 0.25  eval-nurbs {   0.0   1.0 } 0.00001 v~ ] unit-test
{ t } [ test-nurbs get 0.5   eval-nurbs {  -1.0   0.0 } 0.00001 v~ ] unit-test
{ t } [ test-nurbs get 0.75  eval-nurbs {   0.0  -1.0 } 0.00001 v~ ] unit-test

{ t } [ test-nurbs get 0.125 eval-nurbs ${ √2/2 √2/2 } 0.00001 v~ ] unit-test
{ t } [ test-nurbs get 0.375 eval-nurbs ${ -√2/2 √2/2 } 0.00001 v~ ] unit-test
{ t } [ test-nurbs get 0.625 eval-nurbs ${ -√2/2 -√2/2 } 0.00001 v~ ] unit-test
{ t } [ test-nurbs get 0.875 eval-nurbs ${ √2/2 -√2/2 } 0.00001 v~ ] unit-test
