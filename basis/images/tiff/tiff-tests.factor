! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors images.tiff images.viewer io
io.encodings.binary io.files namespaces sequences tools.test ;
IN: images.tiff.tests

: path>tiff ( path -- tiff )
    binary [ input-stream get load-tiff ] with-file-reader ;

: tiff-example1 ( -- tiff )
    "resource:extra/images/testing/square.tiff" path>tiff ;

: tiff-example2 ( -- tiff )
    "resource:extra/images/testing/cube.tiff" path>tiff ;

: tiff-example3 ( -- tiff )
    "resource:extra/images/testing/bi.tiff" path>tiff ;

: tiff-example4 ( -- tiff )
    "resource:extra/images/testing/noise.tiff" path>tiff ;

: tiff-example5 ( -- tiff )
    "resource:extra/images/testing/alpha.tiff" path>tiff ;

: tiff-example6 ( -- tiff )
    "resource:extra/images/testing/color_spectrum.tiff" path>tiff ;

: tiff-example7 ( -- tiff )
    "resource:extra/images/testing/small.tiff" path>tiff ;

: tiff-all. ( -- )
    {
        tiff-example1 tiff-example2 tiff-example3 tiff-example4 tiff-example5
        tiff-example6
    }
    [ execute( -- gif ) tiff>image image. ] each ;

[ 1024 ] [ tiff-example1 ifds>> first bitmap>> length ] unit-test
[ 1024 ] [ tiff-example2 ifds>> first bitmap>> length ] unit-test
[ 131744 ] [ tiff-example3 ifds>> first bitmap>> length ] unit-test
[ 49152 ] [ tiff-example4 ifds>> first bitmap>> length ] unit-test
[ 16 ] [ tiff-example5 ifds>> first bitmap>> length ] unit-test
[ 117504 ] [ tiff-example6 ifds>> first bitmap>> length ] unit-test

