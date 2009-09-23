! Copyright (C) 2009 Keith Lazuka.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors images.gif io io.encodings.binary io.files
math namespaces sequences tools.test math.bitwise ;
IN: images.gif.tests

: path>gif ( path -- loading-gif )
    binary [ input-stream get load-gif ] with-file-reader ;

: gif-example1 ( -- loading-gif )
    "resource:extra/images/testing/symbol-word-16-colors.gif" path>gif ;

: gif-example2 ( -- loading-gif )
    "resource:extra/images/testing/check-256-colors.gif" path>gif ;

: gif-example3 ( -- loading-gif )
    "resource:extra/images/testing/monochrome.gif" path>gif ;

: declared-num-colors ( gif -- n ) flags>> 3 bits 1 + 2^ ;
: actual-num-colors ( gif -- n ) global-color-table>> length 3 /i ;

[ 16 ] [ gif-example1 actual-num-colors ] unit-test
[ 16 ] [ gif-example1 declared-num-colors ] unit-test

[ 256 ] [ gif-example2 actual-num-colors ] unit-test
[ 256 ] [ gif-example2 declared-num-colors ] unit-test

[ 2 ] [ gif-example3 actual-num-colors ] unit-test
[ 2 ] [ gif-example3 declared-num-colors ] unit-test
