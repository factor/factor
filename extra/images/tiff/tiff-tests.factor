! Copyright (C) 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: images.testing images.tiff sequences ;

{
    "vocab:images/testing/tiff/octagon.tiff"
    ! "vocab:images/testing/tiff/elephants.tiff"
    "vocab:images/testing/tiff/noise.tiff"
    "vocab:images/testing/tiff/alpha.tiff"
    "vocab:images/testing/tiff/color_spectrum.tiff"
    "vocab:images/testing/tiff/rgb.tiff"
} [ tiff-image decode-test ] each
