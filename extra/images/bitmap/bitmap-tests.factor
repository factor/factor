USING: images.bitmap images.viewer io.encodings.binary
io.files io.files.unique kernel tools.test ;
IN: images.bitmap.tests

: test-bitmap24 ( -- path )
    "resource:extra/images/test-images/thiswayup24.bmp" ;

: test-bitmap8 ( -- path )
    "resource:extra/images/test-images/rgb8bit.bmp" ;

: test-bitmap4 ( -- path )
    "resource:extra/images/test-images/rgb4bit.bmp" ;

: test-bitmap1 ( -- path )
    "resource:extra/images/test-images/1bit.bmp" ;

[ t ]
[
    test-bitmap24
    [ binary file-contents ] [ load-bitmap ] bi

    "test-bitmap24" unique-file
    [ save-bitmap ] [ binary file-contents ] bi =
] unit-test
