IN: specialized-arrays.tests
USING: tools.test specialized-arrays sequences
specialized-arrays.int specialized-arrays.bool
specialized-arrays.ushort alien.c-types accessors kernel ;

[ t ] [ { 1 2 3 } >int-array int-array? ] unit-test

[ t ] [ int-array{ 1 2 3 } int-array? ] unit-test

[ 2 ] [ int-array{ 1 2 3 } second ] unit-test

[ t ] [ { t f t } >bool-array underlying>> { 1 0 1 } >int-array underlying>> = ] unit-test

[ ushort-array{ 1234 } ] [
    little-endian? B{ 210 4 } B{ 4 210 } ? byte-array>ushort-array
] unit-test

[ B{ 210 4 1 } byte-array>ushort-array ] must-fail
