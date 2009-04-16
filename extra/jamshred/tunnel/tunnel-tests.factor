! Copyright (C) 2007, 2008 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays jamshred.oint jamshred.tunnel kernel math.vectors sequences specialized-arrays.float tools.test ;
IN: jamshred.tunnel.tests

[ 0 ] [ T{ segment f { 0 0 0 } f f f 0 }
        T{ segment f { 1 1 1 } f f f 1 }
        T{ oint f { 0 0 0.25 } }
        nearer-segment number>> ] unit-test

[ 0 ] [ T{ oint f { 0 0 0 } } <straight-tunnel> find-nearest-segment number>> ] unit-test
[ 1 ] [ T{ oint f { 0 0 -1 } } <straight-tunnel> find-nearest-segment number>> ] unit-test
[ 2 ] [ T{ oint f { 0 0.1 -2.1 } } <straight-tunnel> find-nearest-segment number>> ] unit-test

[ 3 ] [ <straight-tunnel> T{ oint f { 0 0 -3.25 } } 0 nearest-segment-forward number>> ] unit-test

[ float-array{ 0 0 0 } ] [ <straight-tunnel> T{ oint f { 0 0 -0.25 } } over first nearest-segment location>> ] unit-test

: test-segment-oint ( -- oint )
    { 0 0 0 } { 0 0 -1 } { 0 1 0 } { -1 0 0 } <oint> ;

[ { -1 0 0 } ] [ test-segment-oint { 1 0 0 } vector-to-centre ] unit-test
[ { 1 0 0 } ] [ test-segment-oint { -1 0 0 } vector-to-centre ] unit-test
[ { 0 -1 0 } ] [ test-segment-oint { 0 1 0 } vector-to-centre ] unit-test
[ { 0 1 0 } ] [ test-segment-oint { 0 -1 0 } vector-to-centre ] unit-test
[ { -1 0 0 } ] [ test-segment-oint { 1 0 -1 } vector-to-centre ] unit-test
[ { 1 0 0 } ] [ test-segment-oint { -1 0 -1 } vector-to-centre ] unit-test
[ { 0 -1 0 } ] [ test-segment-oint { 0 1 -1 } vector-to-centre ] unit-test
[ { 0 1 0 } ] [ test-segment-oint { 0 -1 -1 } vector-to-centre ] unit-test

: simplest-straight-ahead ( -- oint segment )
    { 0 0 0 } { 0 0 -1 } { 0 1 0 } { -1 0 0 } <oint>
    initial-segment ;

[ { 0.0 0.0 0.0 } ] [ simplest-straight-ahead sideways-heading ] unit-test
[ { 0.0 0.0 0.0 } ] [ simplest-straight-ahead sideways-relative-location ] unit-test

: simple-collision-up ( -- oint segment )
    { 0 0 0 } { 0 1 0 } { 0 0 1 } { -1 0 0 } <oint>
    initial-segment ;

[ { 0.0 1.0 0.0 } ] [ simple-collision-up sideways-heading ] unit-test
[ { 0.0 0.0 0.0 } ] [ simple-collision-up sideways-relative-location ] unit-test
[ { 0.0 1.0 0.0 } ]
[ simple-collision-up collision-vector 0 0 0 3array v+ ] unit-test
