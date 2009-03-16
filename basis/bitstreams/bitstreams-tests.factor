! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors bitstreams io io.streams.string kernel tools.test
grouping compression.lzw multiline byte-arrays io.encodings.binary
io.streams.byte-array ;
IN: bitstreams.tests

[ 1 t ]
[ B{ 254 } binary <byte-reader> <bitstream-reader> read-bit ] unit-test

[ 254 8 t ]
[ B{ 254 } binary <byte-reader> <bitstream-reader> 8 swap read-bits ] unit-test

[ 4095 12 t ]
[ B{ 255 255 } binary <byte-reader> <bitstream-reader> 12 swap read-bits ] unit-test

[ B{ 254 } ]
[
    binary <byte-writer> <bitstream-writer> 254 8 rot
    [ write-bits ] keep stream>> >byte-array
] unit-test

[ 255 8 t ]
[ B{ 255 } binary <byte-reader> <bitstream-reader> 8 swap read-bits ] unit-test

[ 255 8 f ]
[ B{ 255 } binary <byte-reader> <bitstream-reader> 9 swap read-bits ] unit-test
