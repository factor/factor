USING: jamshred.oint jamshred.tunnel kernel sequences tools.test ;
IN: temporary

[ 0 ] [ T{ segment T{ oint f { 0 0 0 } } 0 }
        T{ segment T{ oint f { 1 1 1 } } 1 }
        T{ oint f { 0 0 0.25 } }
        nearer-segment segment-number ] unit-test

[ 0 ] [ T{ oint f { 0 0 0 } } <straight-tunnel> find-nearest-segment segment-number ] unit-test
[ 1 ] [ T{ oint f { 0 0 -1 } } <straight-tunnel> find-nearest-segment segment-number ] unit-test
[ 2 ] [ T{ oint f { 0 0.1 -2.1 } } <straight-tunnel> find-nearest-segment segment-number ] unit-test

[ 3 ] [ <straight-tunnel> T{ oint f { 0 0 -3.25 } } 0 nearest-segment-forward segment-number ] unit-test

[ F{ 0 0 0 } ] [ <straight-tunnel> T{ oint f { 0 0 -0.25 } } over first nearest-segment oint-location ] unit-test
