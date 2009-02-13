! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors bitstreams io io.streams.string kernel tools.test
grouping compression.lzw multiline byte-arrays ;
IN: bitstreams.tests

[ 1 ]
[ B{ 254 } <string-reader> <bitstream-reader> read-bit ] unit-test

[ 254 ]
[ B{ 254 } <string-reader> <bitstream-reader> 8 swap read-bits ] unit-test

[ 4095 ]
[ B{ 255 255 } <string-reader> <bitstream-reader> 12 swap read-bits ] unit-test

[ B{ 254 } ]
[
    <string-writer> <bitstream-writer> 254 8 rot
    [ write-bits ] keep output>> >byte-array
] unit-test


/*
[
    
] [
    B{ 7 7 7 8 8 7 7 9 7 }
    [ byte-array>bignum >bin 72 CHAR: 0 pad-head 9 group [ bin> ] map ]
    [ lzw-compress ] bi
] unit-test
*/
