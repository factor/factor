! Copyright (C) 2012 John Benediktsson
! See https://factorcode.org/license.txt for BSD license
USING: math.transforms.bwt tools.test ;

{ "asdf" } [ "asdf" bwt ibwt ] unit-test

{
    29
    "TEXYDST.E.IXIXIXXSSMPPS.B..E.S.EUSFXDIIOIIIT"
} [
    "SIX.MIXED.PIXIES.SIFT.SIXTY.PIXIE.DUST.BOXES" bwt
] unit-test
