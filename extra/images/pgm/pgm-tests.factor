! Copyright (C) 2010 Erik Charlebois.
! See https://factorcode.org/license.txt for BSD license.
USING: images.testing images.pgm sequences ;

{
    "vocab:images/testing/pgm/radial.binary.pgm"
    "vocab:images/testing/pgm/radial.ascii.pgm"
} [ pgm-image decode-test ] each
