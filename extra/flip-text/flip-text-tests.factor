! Copyright (C) 2010 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: flip-text tools.test ;

{
    "068Ɫ95ᔭƐᄅ⇂zʎxʍʌnʇsɹbdouɯʃʞɾᴉɥᵷɟǝpɔqɐZ⅄XMΛՈ⊥SᴚΌԀONW⅂KᒋIH⅁ℲƎᗡϽ𐐒∀"
} [
    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890"
    flip-text
] unit-test

{
    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890"
} [
    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890"
    flip-text flip-text
] unit-test
