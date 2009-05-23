! (c)2009 Joe Groff bsd license
USING: math.vectors.homogeneous tools.test ;
IN: math.vectors.homogeneous.tests

[ { 1.0 2.0 1.0 } ] [ { 1.0 0.0 1.0 } { 0.0 2.0 1.0 } h+ ] unit-test
[ { 1.0 -2.0 1.0 } ] [ { 1.0 0.0 1.0 } { 0.0 2.0 1.0 } h- ] unit-test
[ { 2.0 2.0 2.0 } ] [ { 1.0 0.0 1.0 } { 0.0 2.0 2.0 } h+ ] unit-test
[ { 1.0 2.0 2.0 } ] [ { 1.0 0.0 2.0 } { 0.0 2.0 2.0 } h+ ] unit-test

[ { 2.0 4.0 2.0 } ] [ 2.0 { 1.0 2.0 2.0 } n*h ] unit-test
[ { 2.0 4.0 2.0 } ] [ { 1.0 2.0 2.0 } 2.0 h*n ] unit-test

[ { 0.5 1.5 } ] [ { 1.0 3.0 2.0 } h>v ] unit-test
[ { 0.5 1.5 1.0 } ] [ { 0.5 1.5 } v>h ] unit-test
[ { 0.5 1.5 1.0 } ] [ { 0.5 1.5 } v>h ] unit-test
