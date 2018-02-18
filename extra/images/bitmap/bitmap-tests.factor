USING: images.bitmap images.testing kernel sequences ;

! "vocab:images/testing/bmp/1bit.bmp" bmp-image decode-test
! "vocab:images/testing/bmp/rgb_4bit.bmp" bmp-image decode-test

{
    "vocab:images/testing/bmp/rgb_8bit.bmp"
    "vocab:images/testing/bmp/42red_24bit.bmp"
} [
    bmp-image [ decode-test ] [ encode-test ] 2bi
] each
