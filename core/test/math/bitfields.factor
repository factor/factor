IN: temporary
USING: math test inference kernel ;

[ 0 ] [ { } bitfield ] unit-test
[ 0 ] [ { } bitfield-quot call ] unit-test
[ 256 ] [ 1 { 8 } bitfield ] unit-test
[ 256 ] [ 1 { 8 } bitfield-quot call ] unit-test
[ 268 ] [ 3 1 { 8 2 } bitfield ] unit-test
[ 268 ] [ 3 1 { 8 2 } bitfield-quot call ] unit-test
[ 268 ] [ 1 { 8 { 3 2 } } bitfield ] unit-test
[ 268 ] [ 1 { 8 { 3 2 } } bitfield-quot call ] unit-test
[ 512 ] [ 1 { { 1+ 8 } } bitfield ] unit-test
[ 512 ] [ 1 { { 1+ 8 } } bitfield-quot call ] unit-test
