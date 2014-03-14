! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: images.testing images.tiff ;
IN: images.tiff.tests

"vocab:images/testing/tiff/octagon.tiff" tiff-image decode-test
! "vocab:images/testing/tiff/elephants.tiff" tiff-image decode-test
"vocab:images/testing/tiff/noise.tiff" tiff-image decode-test
"vocab:images/testing/tiff/alpha.tiff" tiff-image decode-test
"vocab:images/testing/tiff/color_spectrum.tiff" tiff-image decode-test
"vocab:images/testing/tiff/rgb.tiff" tiff-image decode-test
