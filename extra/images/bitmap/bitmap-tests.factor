USING: images.bitmap images.testing kernel ;
IN: images.bitmap.tests

! "vocab:images/testing/bmp/1bit.bmp" decode-test
! "vocab:images/testing/bmp/rgb_4bit.bmp" decode-test

"vocab:images/testing/bmp/rgb_8bit.bmp" bmp-image
[ decode-test ] [ encode-test ] 2bi

"vocab:images/testing/bmp/42red_24bit.bmp" bmp-image
[ decode-test ] [ encode-test ] 2bi
