USING: math math.combinatorics.bits tools.test ;

{ 0b101 } [ 0b011 next-permutation-bits ] unit-test
{ 0b110 } [ 0b101 next-permutation-bits ] unit-test

{
    {
        0b00111 0b01011 0b01101 0b01110 0b10011
        0b10101 0b10110 0b11001 0b11010 0b11100
    }
} [ 3 5 all-permutation-bits ] unit-test

{ { 14 22 26 28 38 42 44 50 52 56 } } [ 3 5 [ 2 * ] map-permutation-bits ] unit-test

{ V{ 14 22 26 28 } } [ 3 5 [ even? ] filter-permutation-bits ] unit-test

{ 14 } [ 3 5 [ even? ] find-permutation-bits ] unit-test
{ f } [ 3 5 [ 0 < ] find-permutation-bits ] unit-test

{ 198 } [ 3 5 12 [ + ] reduce-permutation-bits ] unit-test
