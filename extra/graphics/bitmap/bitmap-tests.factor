USING: graphics.bitmap graphics.viewer io.encodings.binary
io.files io.files.unique kernel tools.test ;
IN: graphics.bitmap.tests

: test-bitmap32-alpha ( -- path )
    "resource:extra/graphics/bitmap/test-images/32alpha.bmp" ;

: test-bitmap24 ( -- path )
    "resource:extra/graphics/bitmap/test-images/thiswayup24.bmp" ;

: test-bitmap16 ( -- path )
    "resource:extra/graphics/bitmap/test-images/rgb16bit.bmp" ;

: test-bitmap8 ( -- path )
    "resource:extra/graphics/bitmap/test-images/rgb8bit.bmp" ;

: test-bitmap4 ( -- path )
    "resource:extra/graphics/bitmap/test-images/rgb4bit.bmp" ;

: test-bitmap1 ( -- path )
    "resource:extra/graphics/bitmap/test-images/1bit.bmp" ;

[ t ]
[
    test-bitmap24
    [ binary file-contents ] [ load-bitmap ] bi

    "test-bitmap24" unique-file
    [ save-bitmap ] [ binary file-contents ] bi =
] unit-test
