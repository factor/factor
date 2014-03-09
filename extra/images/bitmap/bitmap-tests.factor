USING: images.bitmap images.loader images.testing kernel ;
IN: images.bitmap.tests

"bmp" bmp-image register-image-class

! "vocab:images/testing/bmp/1bit.bmp" decode-test
! "vocab:images/testing/bmp/rgb_4bit.bmp" decode-test

"vocab:images/testing/bmp/rgb_8bit.bmp"
[ decode-test ] [ bmp-image encode-test ] bi

"vocab:images/testing/bmp/42red_24bit.bmp"
[ decode-test ] [ bmp-image encode-test ] bi
