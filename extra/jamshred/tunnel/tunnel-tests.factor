! Copyright (C) 2007, 2008 Alex Chapman
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays jamshred.oint jamshred.tunnel kernel
math.vectors sequences specialized-arrays tools.test
alien.c-types ;
SPECIALIZED-ARRAY: float
IN: jamshred.tunnel.tests

: test-segment-oint ( -- oint )
    { 0 0 0 } { 0 0 -1 } { 0 1 0 } { -1 0 0 } <oint> ;

{ { -1 0 0 } } [ test-segment-oint { 1 0 0 } vector-to-center ] unit-test
{ { 1 0 0 } } [ test-segment-oint { -1 0 0 } vector-to-center ] unit-test
{ { 0 -1 0 } } [ test-segment-oint { 0 1 0 } vector-to-center ] unit-test
{ { 0 1 0 } } [ test-segment-oint { 0 -1 0 } vector-to-center ] unit-test
{ { -1 0 0 } } [ test-segment-oint { 1 0 -1 } vector-to-center ] unit-test
{ { 1 0 0 } } [ test-segment-oint { -1 0 -1 } vector-to-center ] unit-test
{ { 0 -1 0 } } [ test-segment-oint { 0 1 -1 } vector-to-center ] unit-test
{ { 0 1 0 } } [ test-segment-oint { 0 -1 -1 } vector-to-center ] unit-test

: simplest-straight-ahead ( -- oint segment )
    { 0 0 0 } { 0 0 -1 } { 0 1 0 } { -1 0 0 } <oint>
    initial-segment ;

{ { 0.0 0.0 0.0 } } [ simplest-straight-ahead sideways-heading ] unit-test
{ { 0.0 0.0 0.0 } } [ simplest-straight-ahead sideways-relative-location ] unit-test

: simple-collision-up ( -- oint segment )
    { 0 0 0 } { 0 1 0 } { 0 0 1 } { -1 0 0 } <oint>
    initial-segment ;

{ { 0.0 1.0 0.0 } } [ simple-collision-up sideways-heading ] unit-test
{ { 0.0 0.0 0.0 } } [ simple-collision-up sideways-relative-location ] unit-test
{ { 0.0 1.0 0.0 } }
[ simple-collision-up collision-vector 0 0 0 3array v+ ] unit-test
