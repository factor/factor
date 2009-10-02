USING: images.bitmap images.viewer io.encodings.binary
io.files io.files.unique kernel tools.test images.loader
literals sequences checksums.md5 checksums ;
IN: images.bitmap.tests

CONSTANT: test-bitmap24 "vocab:images/testing/bmp/thiswayup24.bmp"

CONSTANT: test-bitmap8 "vocab:images/testing/bmp/rgb8bit.bmp"

CONSTANT: test-bitmap4 "vocab:images/testing/bmp/rgb4bit.bmp"

CONSTANT: test-bitmap1 "vocab:images/testing/bmp/1bit.bmp"

CONSTANT: test-40 "vocab:images/testing/bmp/40red24bit.bmp"
CONSTANT: test-41 "vocab:images/testing/bmp/41red24bit.bmp"
CONSTANT: test-42 "vocab:images/testing/bmp/42red24bit.bmp"
CONSTANT: test-43 "vocab:images/testing/bmp/43red24bit.bmp"

${
    test-bitmap8
    test-bitmap24
    "vocab:ui/render/test/reference.bmp"
} [ [ ] swap [ load-image drop ] curry unit-test ] each


: test-bitmap-save ( path -- ? )
    [ md5 checksum-file ]
    [ load-image ] bi
    "bitmap-save-test" ".bmp" make-unique-file
    [ save-bitmap ]
    [ md5 checksum-file ] bi = ;

[
    t   
] [
    ${
        test-40
        test-41
        test-42
        test-43
        test-bitmap24
    } [ test-bitmap-save ] all?
] unit-test
