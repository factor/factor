! Copyright (C) 2010 Erik Charlebois.
! See https://factorcode.org/license.txt for BSD license.
USING: images.testing images.ppm sequences ;

{
    "vocab:images/testing/ppm/binary.ppm"
    "vocab:images/testing/ppm/ascii.ppm"
} [ ppm-image decode-test ] each
