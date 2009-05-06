IN: specialized-arrays.tests
USING: tools.test specialized-arrays sequences
specialized-arrays.int specialized-arrays.bool
specialized-arrays.ushort alien.c-types accessors kernel
specialized-arrays.direct.int specialized-arrays.char arrays ;

[ t ] [ { 1 2 3 } >int-array int-array? ] unit-test

[ t ] [ int-array{ 1 2 3 } int-array? ] unit-test

[ 2 ] [ int-array{ 1 2 3 } second ] unit-test

[ t ] [ { t f t } >bool-array underlying>> { 1 0 1 } >char-array underlying>> = ] unit-test

[ ushort-array{ 1234 } ] [
    little-endian? B{ 210 4 } B{ 4 210 } ? byte-array>ushort-array
] unit-test

[ B{ 210 4 1 } byte-array>ushort-array ] must-fail

[ { 3 1 3 3 7 } ] [
    int-array{ 3 1 3 3 7 } malloc-byte-array 5 <direct-int-array> >array
] unit-test