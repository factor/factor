USING: images.bitmap images.viewer io.encodings.binary
io.files io.files.unique kernel tools.test images.loader
literals sequences ;
IN: images.bitmap.tests

CONSTANT: test-bitmap24 "vocab:images/test-images/thiswayup24.bmp"

CONSTANT: test-bitmap8 "vocab:images/test-images/rgb8bit.bmp"

CONSTANT: test-bitmap4 "vocab:images/test-images/rgb4bit.bmp"

CONSTANT: test-bitmap1 "vocab:images/test-images/1bit.bmp"

[ t ]
[
    test-bitmap24
    [ binary file-contents ] [ load-image ] bi

    "test-bitmap24" unique-file
    [ save-bitmap ] [ binary file-contents ] bi =
] unit-test

{
    $ test-bitmap8
    $ test-bitmap24
    "vocab:ui/render/test/reference.bmp"
} [ [ ] swap [ load-image drop ] curry unit-test ] each