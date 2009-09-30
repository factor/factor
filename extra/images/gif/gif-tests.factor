! Copyright (C) 2009 Keith Lazuka.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors bitstreams compression.lzw images.gif io
io.encodings.binary io.files kernel math math.bitwise
math.parser namespaces prettyprint sequences tools.test images.viewer ;
QUALIFIED-WITH: bitstreams bs
IN: images.gif.tests

: path>gif ( path -- loading-gif )
    binary [ input-stream get load-gif ] with-file-reader ;

: gif-example1 ( -- loading-gif )
    "resource:extra/images/testing/circle.gif" path>gif ;

: gif-example2 ( -- loading-gif )
    "resource:extra/images/testing/checkmark.gif" path>gif ;

: gif-example3 ( -- loading-gif )
    "resource:extra/images/testing/monochrome.gif" path>gif ;

: gif-example4 ( -- loading-gif )
    "resource:extra/images/testing/noise.gif" path>gif ;

: gif-example5 ( -- loading-gif )
    "resource:extra/images/testing/alpha.gif" path>gif ;

: gif-example6 ( -- loading-gif )
    "resource:extra/images/testing/astronaut_animation.gif" path>gif ;

: gif-all. ( -- )
    {
        gif-example1 gif-example2 gif-example3 gif-example4 gif-example5
        gif-example6
    }
    [ execute( -- gif ) gif>image image. ] each ;

: declared-num-colors ( gif -- n ) flags>> 3 bits 1 + 2^ ;
: actual-num-colors ( gif -- n ) global-color-table>> length ;

[ 16 ] [ gif-example1 actual-num-colors ] unit-test
[ 16 ] [ gif-example1 declared-num-colors ] unit-test

[ 256 ] [ gif-example2 actual-num-colors ] unit-test
[ 256 ] [ gif-example2 declared-num-colors ] unit-test

[ 2 ] [ gif-example3 actual-num-colors ] unit-test
[ 2 ] [ gif-example3 declared-num-colors ] unit-test

: >index-stream ( gif -- seq )
    [ compressed-bytes>> ]
    [ image-descriptor>> first-code-size>> ] bi
    gif-lzw-uncompress ;

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

[
    B{
        255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255
        0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 255
        0 0 0 255 0 0 0 255 255 255 255 255 255 255 255 255 0 0 0 255 0 0 0 255
        0 0 0 255 0 0 0 255 0 0 0 255 0 0 0 255 0 0 0 255 0 0 0 255
        0 0 0 255 255 255 255 255 0 0 0 255 0 0 0 255 255 255 255 255 0 0 0 255
        0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 255
    }
] [ gif-example3 gif>image bitmap>> ] unit-test

[
    BV{
        0 1
        1 0
    }
] [ gif-example5 >index-stream ] unit-test

[
    B{
        255 000 000 255     000 000 000 000
        000 000 000 000     255 000 000 255
    }
] [ gif-example5 gif>image bitmap>> ] unit-test

[ 100 ] [ gif-example1 >index-stream length ] unit-test
[ 870 ] [ gif-example2 >index-stream length ] unit-test
[ 16384 ] [ gif-example4 >index-stream length ] unit-test

! example6 is a GIF animation and the first frame contains 1768 pixels
[ 1768 ] [ gif-example6 >index-stream length ] unit-test
