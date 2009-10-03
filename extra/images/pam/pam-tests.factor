! Copyright (C) 2009 Keith Lazuka.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors byte-arrays images.loader images.pam
images.testing io io.encodings.binary io.files
io.streams.byte-array kernel quotations tools.test ;
IN: images.pam.tests

! ----------- Encoder Tests ------------------------------

"vocab:images/testing/pam/rgb1x1.pam" pam-image encode-test
"vocab:images/testing/pam/rgba1x1.pam" pam-image encode-test
"vocab:images/testing/pam/rgb2x2.pam" pam-image encode-test
"vocab:images/testing/pam/rgba2x2.pam" pam-image encode-test
"vocab:images/testing/pam/rgb3x3.pam" pam-image encode-test
"vocab:images/testing/pam/rgba3x3.pam" pam-image encode-test

! ----------- Decoder Tests ------------------------------

! 1x1

[ { 1 1 } ] [ "vocab:images/testing/pam/rgb1x1.pam" load-image dim>> ] unit-test

[ B{ 0 0 0 } ]
[ "vocab:images/testing/pam/rgb1x1.pam" load-image bitmap>> ] unit-test

[ B{ 0 0 0 0 } ]
[ "vocab:images/testing/pam/rgba1x1.pam" load-image bitmap>> ] unit-test

! 2x2

[ { 2  2 } ] [ "vocab:images/testing/pam/rgb2x2.pam" load-image dim>> ] unit-test

[ B{ 0 0 0 255 255 255 255 255 255 0 0 0 } ]
[ "vocab:images/testing/pam/rgb2x2.pam" load-image bitmap>> ] unit-test

[ B{ 0 0 0 255 255 255 255 0 255 255 255 0 0 0 0 255 } ]
[ "vocab:images/testing/pam/rgba2x2.pam" load-image bitmap>> ] unit-test

! 3x3

[
    B{
        255   0   0       0 255   0       0   0 255
          4 252 253     254   1 127     252 253   2
        255 255 255       0   0   0     255 255 255
    }
]
[ "vocab:images/testing/pam/rgb3x3.pam" load-image bitmap>> ] unit-test

[
    B{
        255   0   0 255       0 255   0 255       0   0 255 255
          4 252 253 255     254   1 127 255     252 253   2 255
        255 255 255 255       0   0   0 255     255 255 255   0
    }
]
[ "vocab:images/testing/pam/rgba3x3.pam" load-image bitmap>> ] unit-test
