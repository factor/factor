! Copyright (C) 2012 John Benediktsson
! See http://factorcode.org/license.txt for BSD license
USING: math.transforms.bwt tools.test ;
IN: math.transforms.bwt.tests

{ "asdf" } [ "asdf" bwt ibwt ] unit-test

{
    29
    "TEXYDST.E.IXIXIXXSSMPPS.B..E.S.EUSFXDIIOIIIT"
} [
    "SIX.MIXED.PIXIES.SIFT.SIXTY.PIXIE.DUST.BOXES" bwt
] unit-test
