! Copyright (C) 2025 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: base16 base32 base36 base45 base58 base64 combinators
grouping math.parser proquint sequences ;

IN: multibase

! https://github.com/multiformats/multibase

: multibase> ( multibase -- seq )
    unclip {
        ! { CHAR: \0 [ ] } ! none
        { CHAR: 0 [ 8 <groups> [ bin> ] map ] }
        ! { CHAR: 1 [ ] } ! none
        { CHAR: 7 [ 3 <groups> [ oct> ] map ] }
        { CHAR: 9 [ 3 <groups> [ dec> ] map ] }
        { CHAR: f [ base16> ] }
        { CHAR: F [ base16> ] }
        { CHAR: v [ base32hex> ] }
        { CHAR: V [ base32hex> ] }
        { CHAR: t [ base32hex> ] }
        { CHAR: T [ base32hex> ] }
        { CHAR: b [ base32> ] }
        { CHAR: B [ base32> ] }
        { CHAR: c [ base32> ] }
        { CHAR: C [ base32> ] }
        ! { CHAR: h [ ] } ! base32z
        { CHAR: k [ base36> ] }
        { CHAR: K [ base36> ] }
        { CHAR: R [ base45> ] }
        { CHAR: z [ base58> ] }
        ! { CHAR: Z [ ] } ! base58flickr
        { CHAR: m [ base64> ] }
        { CHAR: M [ base64> ] }
        { CHAR: u [ urlsafe-base64> ] }
        { CHAR: U [ urlsafe-base64> ] }
        { CHAR: p [ quint> ] }
        ! { CHAR: Q [ ] } ! none
        ! { CHAR: \ [ ] } ! none
        ! { CHAR: 🚀 [ ] } ! base256emoji
    } case ;

: >multibase ( seq base-format -- multibase )
    {
        ! { "none" [ ] }
        { "base2" [ [ >bin 8 CHAR: 0 pad-head ] map concat CHAR: 0 prefix ] }
        { "base8" [ [ >oct 3 CHAR: 0 pad-head ] map concat CHAR: 7 prefix ] }
        { "base10" [ [ >dec 3 CHAR: 0 pad-head ] map concat CHAR: 9 prefix ] }
        { "base16" [ >base16 CHAR: f prefix ] }
        { "base16upper" [ >base16 CHAR: F prefix ] }
        { "base32hex" [ >base32hex CHAR: v prefix ] }
        { "base32hexupper" [ >base32hex CHAR: V prefix ] }
        { "base32hexpad" [ >base32hex-lines CHAR: t prefix ] }
        { "base32hexpadupper" [ >base32hex-lines CHAR: T prefix ] }
        { "base32" [ >base32 CHAR: b prefix ] }
        { "base32upper" [ >base32 CHAR: B prefix ] }
        { "base32pad" [ >base32-lines CHAR: c prefix ] }
        { "base32padupper" [ >base32-lines CHAR: C prefix ] }
        ! { "base32z" [ ] }
        { "base36" [ >base36 CHAR: k prefix ] }
        { "base36upper" [ >base36 CHAR: K prefix ] }
        { "base45" [ >base45 CHAR: R prefix ] }
        { "base58btc" [ >base58 CHAR: z prefix ] }
        ! { "base58flickr" [ ] }
        { "base64" [ >base64 CHAR: m prefix ] }
        { "base64pad" [ >base64-lines CHAR: M prefix ] }
        { "base64url" [ >urlsafe-base64 CHAR: u prefix  ] }
        { "base64urlpad" [ >urlsafe-base64-lines CHAR: U prefix ] }
        ! { "proquint" [ ] }
        ! { "base256emoji" [ ] }
    } case ;
