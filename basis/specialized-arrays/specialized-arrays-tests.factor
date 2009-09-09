IN: specialized-arrays.tests
USING: tools.test alien.syntax specialized-arrays sequences
specialized-arrays.int specialized-arrays.bool
specialized-arrays.ushort alien.c-types accessors kernel
specialized-arrays.char specialized-arrays.uint
specialized-arrays.float arrays combinators compiler ;

[ t ] [ { 1 2 3 } >int-array int-array? ] unit-test

[ t ] [ int-array{ 1 2 3 } int-array? ] unit-test

[ 2 ] [ int-array{ 1 2 3 } second ] unit-test

[ t ] [
    { t f t } >bool-array underlying>>
    { 1 0 1 } "bool" heap-size {
        { 1 [ >char-array ] }
        { 4 [ >uint-array ] }
    } case underlying>> =
] unit-test

[ ushort-array{ 1234 } ] [
    little-endian? B{ 210 4 } B{ 4 210 } ? byte-array>ushort-array
] unit-test

[ B{ 210 4 1 } byte-array>ushort-array ] must-fail

[ { 3 1 3 3 7 } ] [
    int-array{ 3 1 3 3 7 } malloc-byte-array 5 <direct-int-array> >array
] unit-test

[ f ] [ float-array{ 4 3 2 1 } dup clone [ underlying>> ] bi@ eq? ] unit-test

[ f ] [ [ float-array{ 4 3 2 1 } dup clone [ underlying>> ] bi@ eq? ] compile-call ] unit-test

[ ushort-array{ 0 0 0 } ] [
    3 ALIEN: 123 100 <direct-ushort-array> new-sequence
    dup [ drop 0 ] change-each
] unit-test
