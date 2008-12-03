USING: jamshred.oint tools.test ;
IN: jamshred.oint-tests

[ { 0 -1 -1 } ] [ { 0 1 -1 } { 0 -1 0 } reflect ] unit-test
[ { 0 1 0 } ] [ { 1 1 0 } { 1 0 0 } proj-perp ] unit-test
[ { 1 0 0 } ] [ { 1 1 0 } { 0 1 0 } proj-perp ] unit-test
[ { 1/2 -1/2 0 } ] [ { 1 0 0 } { 1 1 0 } proj-perp ] unit-test
[ { -1/2 1/2 0 } ] [ { 0 1 0 } { 1 1 0 } proj-perp ] unit-test
