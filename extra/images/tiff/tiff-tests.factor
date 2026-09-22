! Copyright (C) 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays byte-arrays endian images.testing images.tiff
io.encodings.binary io.streams.byte-array kernel sequences tools.test ;

{
    "vocab:images/testing/tiff/octagon.tiff"
    ! "vocab:images/testing/tiff/elephants.tiff"
    "vocab:images/testing/tiff/noise.tiff"
    "vocab:images/testing/tiff/alpha.tiff"
    "vocab:images/testing/tiff/color_spectrum.tiff"
    "vocab:images/testing/tiff/rgb.tiff"
} [ tiff-image decode-test ] each

! Text metadata uses offsets; all ASCII tag branches preserve their value.
{ {
    { "hello" document-name } { "hello" image-description }
    { "hello" tiff-make } { "hello" tiff-model }
    { "hello" software } { "hello" date-time }
    { "hello" artist } { "hello" host-computer }
} } [
    { 269 270 271 272 305 306 315 316 } [
        2 5 0 <ifd-entry>
        B{ 104 101 108 108 111 } binary [
            [ process-ifd-entry 2array ] with-little-endian
        ] with-byte-reader
    ] map
] unit-test
