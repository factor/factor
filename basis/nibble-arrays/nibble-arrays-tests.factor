USING: nibble-arrays tools.test sequences kernel math ;
IN: nibble-arrays.tests

[ t ] [ 16 iota dup >nibble-array sequence= ] unit-test
[ N{ 4 2 1 3 } ] [ N{ 3 1 2 4 } reverse ] unit-test
[ N{ 1 4 9 0 9 4 } ] [ N{ 1 2 3 4 5 6 } [ sq ] map ] unit-test
