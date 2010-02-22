! Copyright (C) 2009 Doug Coleman, Keith Lazuka
! See http://factorcode.org/license.txt for BSD license.
USING: images.testing io.directories ;
IN: images.png.tests

! Test files from PngSuite (http://www.libpng.org/pub/png/pngsuite.html)

! The subset of the suite that should work given the current implementation.
"vocab:images/testing/png" [
    "basn2c08.png" decode-test
    "basn6a08.png" decode-test
    "f00n2c08.png" decode-test
    "f01n2c08.png" decode-test
    "f02n2c08.png" decode-test
    "f03n2c08.png" decode-test
    "f04n2c08.png" decode-test
    "z00n2c08.png" decode-test
    "z03n2c08.png" decode-test
    "z06n2c08.png" decode-test
    "z09n2c08.png" decode-test
] with-directory

! The current PNG decoder implementation is very limited,
! so the entire test suite is not currently enabled.
! "vocab:images/testing/png/suite" [
!     "basi0g01.png" decode-test
!     "basi0g02.png" decode-test
!     "basi0g04.png" decode-test
!     "basi0g08.png" decode-test
!     "basi0g16.png" decode-test
!     "basi2c08.png" decode-test
!     "basi2c16.png" decode-test
!     "basi3p01.png" decode-test
!     "basi3p02.png" decode-test
!     "basi3p04.png" decode-test
!     "basi3p08.png" decode-test
!     "basi4a08.png" decode-test
!     "basi4a16.png" decode-test
!     "basi6a08.png" decode-test
!     "basi6a16.png" decode-test
!     "basn0g01.png" decode-test
!     "basn0g02.png" decode-test
!     "basn0g04.png" decode-test
!     "basn0g08.png" decode-test
!     "basn0g16.png" decode-test
!     "basn2c08.png" decode-test
!     "basn2c16.png" decode-test
!     "basn3p01.png" decode-test
!     "basn3p02.png" decode-test
!     "basn3p04.png" decode-test
!     "basn3p08.png" decode-test
!     "basn4a08.png" decode-test
!     "basn4a16.png" decode-test
!     "basn6a08.png" decode-test
!     "basn6a16.png" decode-test
!     "bgai4a08.png" decode-test
!     "bgai4a16.png" decode-test
!     "bgan6a08.png" decode-test
!     "bgan6a16.png" decode-test
!     "bgbn4a08.png" decode-test
!     "bggn4a16.png" decode-test
!     "bgwn6a08.png" decode-test
!     "bgyn6a16.png" decode-test
!     "ccwn2c08.png" decode-test
!     "ccwn3p08.png" decode-test
!     "cdfn2c08.png" decode-test
!     "cdhn2c08.png" decode-test
!     "cdsn2c08.png" decode-test
!     "cdun2c08.png" decode-test
!     "ch1n3p04.png" decode-test
!     "ch2n3p08.png" decode-test
!     "cm0n0g04.png" decode-test
!     "cm7n0g04.png" decode-test
!     "cm9n0g04.png" decode-test
!     "cs3n2c16.png" decode-test
!     "cs3n3p08.png" decode-test
!     "cs5n2c08.png" decode-test
!     "cs5n3p08.png" decode-test
!     "cs8n2c08.png" decode-test
!     "cs8n3p08.png" decode-test
!     "ct0n0g04.png" decode-test
!     "ct1n0g04.png" decode-test
!     "ctzn0g04.png" decode-test
!     "f00n0g08.png" decode-test
!     "f00n2c08.png" decode-test
!     "f01n0g08.png" decode-test
!     "f01n2c08.png" decode-test
!     "f02n0g08.png" decode-test
!     "f02n2c08.png" decode-test
!     "f03n0g08.png" decode-test
!     "f03n2c08.png" decode-test
!     "f04n0g08.png" decode-test
!     "f04n2c08.png" decode-test
!     "g03n0g16.png" decode-test
!     "g03n2c08.png" decode-test
!     "g03n3p04.png" decode-test
!     "g04n0g16.png" decode-test
!     "g04n2c08.png" decode-test
!     "g04n3p04.png" decode-test
!     "g05n0g16.png" decode-test
!     "g05n2c08.png" decode-test
!     "g05n3p04.png" decode-test
!     "g07n0g16.png" decode-test
!     "g07n2c08.png" decode-test
!     "g07n3p04.png" decode-test
!     "g10n0g16.png" decode-test
!     "g10n2c08.png" decode-test
!     "g10n3p04.png" decode-test
!     "g25n0g16.png" decode-test
!     "g25n2c08.png" decode-test
!     "g25n3p04.png" decode-test
!     "oi1n0g16.png" decode-test
!     "oi1n2c16.png" decode-test
!     "oi2n0g16.png" decode-test
!     "oi2n2c16.png" decode-test
!     "oi4n0g16.png" decode-test
!     "oi4n2c16.png" decode-test
!     "oi9n0g16.png" decode-test
!     "oi9n2c16.png" decode-test
!     "pngsuite_logo.png" decode-test
!     "pp0n2c16.png" decode-test
!     "pp0n6a08.png" decode-test
!     "ps1n0g08.png" decode-test
!     "ps1n2c16.png" decode-test
!     "ps2n0g08.png" decode-test
!     "ps2n2c16.png" decode-test
!     "s01i3p01.png" decode-test
!     "s01n3p01.png" decode-test
!     "s02i3p01.png" decode-test
!     "s02n3p01.png" decode-test
!     "s03i3p01.png" decode-test
!     "s03n3p01.png" decode-test
!     "s04i3p01.png" decode-test
!     "s04n3p01.png" decode-test
!     "s05i3p02.png" decode-test
!     "s05n3p02.png" decode-test
!     "s06i3p02.png" decode-test
!     "s06n3p02.png" decode-test
!     "s07i3p02.png" decode-test
!     "s07n3p02.png" decode-test
!     "s08i3p02.png" decode-test
!     "s08n3p02.png" decode-test
!     "s09i3p02.png" decode-test
!     "s09n3p02.png" decode-test
!     "s32i3p04.png" decode-test
!     "s32n3p04.png" decode-test
!     "s33i3p04.png" decode-test
!     "s33n3p04.png" decode-test
!     "s34i3p04.png" decode-test
!     "s34n3p04.png" decode-test
!     "s35i3p04.png" decode-test
!     "s35n3p04.png" decode-test
!     "s36i3p04.png" decode-test
!     "s36n3p04.png" decode-test
!     "s37i3p04.png" decode-test
!     "s37n3p04.png" decode-test
!     "s38i3p04.png" decode-test
!     "s38n3p04.png" decode-test
!     "s39i3p04.png" decode-test
!     "s39n3p04.png" decode-test
!     "s40i3p04.png" decode-test
!     "s40n3p04.png" decode-test
!     "tbbn1g04.png" decode-test
!     "tbbn2c16.png" decode-test
!     "tbbn3p08.png" decode-test
!     "tbgn2c16.png" decode-test
!     "tbgn3p08.png" decode-test
!     "tbrn2c08.png" decode-test
!     "tbwn1g16.png" decode-test
!     "tbwn3p08.png" decode-test
!     "tbyn3p08.png" decode-test
!     "tp0n1g08.png" decode-test
!     "tp0n2c08.png" decode-test
!     "tp0n3p08.png" decode-test
!     "tp1n3p08.png" decode-test
!     "x00n0g01.png" decode-test
!     "xcrn0g04.png" decode-test
!     "xlfn0g04.png" decode-test
!     "z00n2c08.png" decode-test
!     "z03n2c08.png" decode-test
!     "z06n2c08.png" decode-test
!     "z09n2c08.png" decode-test
! ] with-directory
