! Copyright (C) 2009 Keith Lazuka.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors compression.lzw images.gif images.testing io
io.encodings.binary io.files kernel math math.bitwise
namespaces sequences tools.test ;
IN: images.gif.tests

{
    "vocab:images/testing/gif/circle.gif"
    "vocab:images/testing/gif/checkmark.gif"
    "vocab:images/testing/gif/monochrome.gif"
    "vocab:images/testing/gif/alpha.gif"
    "vocab:images/testing/gif/noise.gif"
    "vocab:images/testing/gif/astronaut_animation.gif"
} [ gif-image decode-test ] each

: path>gif ( path -- gif )
    binary [ input-stream get load-gif ] with-file-reader ;

: circle.gif ( -- gif )
    "vocab:images/testing/gif/circle.gif" path>gif ;

: checkmark.gif ( -- gif )
    "vocab:images/testing/gif/checkmark.gif" path>gif ;

: monochrome.gif ( -- gif )
    "vocab:images/testing/gif/monochrome.gif" path>gif ;

: alpha.gif ( -- gif )
    "vocab:images/testing/gif/alpha.gif" path>gif ;

: declared-num-colors ( gif -- n ) flags>> 3 bits 1 + 2^ ;
: actual-num-colors ( gif -- n ) global-color-table>> length ;

{ 2 } [ monochrome.gif actual-num-colors ] unit-test
{ 2 } [ monochrome.gif declared-num-colors ] unit-test

{ 16 } [ circle.gif actual-num-colors ] unit-test
{ 16 } [ circle.gif declared-num-colors ] unit-test

{ 256 } [ checkmark.gif actual-num-colors ] unit-test
{ 256 } [ checkmark.gif declared-num-colors ] unit-test

: >index-stream ( gif -- seq )
    [ compressed-bytes>> ]
    [ image-descriptor>> first-code-size>> ] bi
    gif-lzw-uncompress ;

{
    BV{
        0 0 0 0 0 0
        1 0 0 0 0 1
        1 1 0 0 1 1
        1 1 1 1 1 1
        1 0 1 1 0 1
        1 0 0 0 0 1
    }
} [ monochrome.gif >index-stream ] unit-test

{
    BV{
        0 1
        1 0
    }
} [ alpha.gif >index-stream ] unit-test
