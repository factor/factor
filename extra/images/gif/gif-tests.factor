! Copyright (C) 2009 Keith Lazuka.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors bitstreams compression.lzw-gif images.gif io
io.encodings.binary io.files kernel math math.bitwise
math.parser namespaces prettyprint sequences tools.test ;
QUALIFIED-WITH: bitstreams bs
IN: images.gif.tests

: path>gif ( path -- loading-gif )
    binary [ input-stream get load-gif ] with-file-reader ;

: gif-example1 ( -- loading-gif )
    "resource:extra/images/testing/symbol-word.gif" path>gif ;

: gif-example2 ( -- loading-gif )
    "resource:extra/images/testing/check-256-colors.gif" path>gif ;

: gif-example3 ( -- loading-gif )
    "resource:extra/images/testing/monochrome.gif" path>gif ;

: gif-example4 ( -- loading-gif )
    "resource:extra/images/testing/noise.gif" path>gif ;

: declared-num-colors ( gif -- n ) flags>> 3 bits 1 + 2^ ;
: actual-num-colors ( gif -- n ) global-color-table>> length 3 /i ;

[ 16 ] [ gif-example1 actual-num-colors ] unit-test
[ 16 ] [ gif-example1 declared-num-colors ] unit-test

[ 256 ] [ gif-example2 actual-num-colors ] unit-test
[ 256 ] [ gif-example2 declared-num-colors ] unit-test

[ 2 ] [ gif-example3 actual-num-colors ] unit-test
[ 2 ] [ gif-example3 declared-num-colors ] unit-test

: >index-stream ( gif -- seq )
    [ image-descriptor>> first-code-size>> ]
    [ compressed-bytes>> ] bi
    lzw-uncompress ;

[
    BV{
        0 0 0 0 0 0
        1 0 0 0 0 1
        1 1 0 0 1 1
        1 1 1 1 1 1
        1 0 1 1 0 1
        1 0 0 0 0 1
    }
] [ gif-example3 >index-stream ] unit-test


