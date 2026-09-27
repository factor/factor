! Copyright (C) 2026 John Benediktsson.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays byte-arrays compression.deflate
compression.deflate.private kernel math sequences tools.test ;
IN: compression.deflate.tests

! Independent raw DEFLATE fixtures generated with Python zlib (wbits=-15).
{ B{ } } [ B{ 3 0 } inflate ] unit-test

{ B{ 104 101 108 108 111 } } [ B{ 203 72 205 201 201 7 0 } inflate ] unit-test

{ B{ 97 98 99 97 98 99 97 98 99 97 98 99 } } [ B{ 75 76 74 78 132 33 0 } inflate ] unit-test

{ t } [
    256 <iota> >byte-array
    [ B{ 1 0 1 255 254 } prepend inflate ] keep =
] unit-test

{ t } [
    B{ 237 198 49 1 0 16 0 0 193 42 170 61 18 232 63 208 194 114 211 93 243 180 218 61 70 238
    238 238 238 238 238 238 238 238 238 238 238 238 238 238 238 238 238 238 238 238 238 238 159
    126 1 } inflate
    1000 B{ 97 98 114 97 99 97 100 97 98 114 97 32 } <repetition> concat >byte-array =
] unit-test

{ t } [
    B{ 202 72 205 201 201 87 200 24 37 71 73 170 146 0 0 0 0 255 255 27 37 71 73 90 144 0 } inflate
    200 B{ 104 101 108 108 111 32 } <repetition> concat >byte-array =
] unit-test

! Empty and multi-block stored streams, including nonzero alignment padding.
{ B{ } } [ B{ 249 0 0 255 255 } inflate ] unit-test
{ B{ 1 2 3 4 } } [
    B{ 0 2 0 253 255 1 2 1 2 0 253 255 3 4 } inflate
] unit-test

{ B{ 3 0 } } [ B{ } deflate ] unit-test
{ B{ 203 72 205 201 201 7 0 } } [ B{ 104 101 108 108 111 } deflate ] unit-test
{ t } [ 100000 97 <array> >byte-array [ deflate inflate ] keep = ] unit-test
{ t } [ 256 <iota> >byte-array [ deflate inflate ] keep = ] unit-test
{ t } [ 70000 [ 256 mod ] B{ } map-integers-as [ stored-deflate inflate ] keep = ] unit-test
{ t } [ 10000 97 <array> >byte-array deflate length 100 < ] unit-test

! Invalid block type, complement, truncation, and references before history.
[ B{ 7 } inflate ] [ invalid-deflate? ] must-fail-with
[ B{ 1 1 0 0 0 97 } inflate ] [ invalid-deflate? ] must-fail-with
[ B{ } inflate ] [ invalid-deflate? ] must-fail-with
[ B{ 1 1 0 254 255 } inflate ] [ invalid-deflate? ] must-fail-with
[ B{ 3 } inflate ] [ invalid-deflate? ] must-fail-with
[ B{ 3 2 0 } inflate ] [ invalid-deflate? ] must-fail-with

! Invalid Huffman alphabets.
[ { 1 1 1 } f huffman-table ] [ invalid-deflate? ] must-fail-with
[ { 2 2 } t huffman-table ] [ invalid-deflate? ] must-fail-with
[ { 0 0 } t huffman-table ] [ invalid-deflate? ] must-fail-with

! Independently constructed RFC 1951 boundary and malformed streams.
! Reserved length symbol 286.
[ B{ 27 3 } inflate ] [ invalid-deflate? ] must-fail-with

! Reserved length symbol 287.
[ B{ 27 7 } inflate ] [ invalid-deflate? ] must-fail-with

! Reserved distance symbol 30.
[ B{ 75 4 62 } inflate ] [ invalid-deflate? ] must-fail-with

! Reserved distance symbol 31.
[ B{ 75 4 126 } inflate ] [ invalid-deflate? ] must-fail-with

! Single end-of-block code and no distance alphabet.
{ B{ } } [ B{ 5 192 1 4 0 0 0 0 16 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
    0 128 0 } inflate ] unit-test

! Literal-only dynamic block with an empty distance alphabet.
{ B{ 65 } } [ B{ 5 192 1 4 0 0 0 0 16 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
    0 0 128 4 } inflate ] unit-test

! Missing end-of-block code.
[ B{ 5 192 1 4 0 0 0 0 16 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 }
    inflate ] [ invalid-deflate? ] must-fail-with

! Oversubscribed literal alphabet in a dynamic header.
[ B{ 5 192 1 4 0 0 0 0 16 0 0 0 0 0 0 0 0 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 128 0 }
    inflate ] [ invalid-deflate? ] must-fail-with

! Reserved HLIT value.
[ B{ 245 0 } inflate ] [ invalid-deflate? ] must-fail-with

! Repeat code 16 before any code length.
[ B{ 5 0 2 36 } inflate ] [ invalid-deflate? ] must-fail-with

! Code-length repeat exceeds HLIT + HDIST.
[ B{ 5 0 128 228 255 31 } inflate ] [ invalid-deflate? ] must-fail-with

! Maximum distance (32768), maximum length (258), and cross-block history.
{ t } [
    32768 [ 256 mod ] B{ } map-integers-as
    [ B{ 0 0 128 255 127 } prepend B{ 27 189 255 31 0 } append inflate ]
    [ dup 258 head append ] bi =
] unit-test

! Incompressible input selects a stored block.
{ 1 } [ 256 <iota> >byte-array deflate first ] unit-test

! Exactly full stored blocks and empty stored input.
{ t } [ 65535 97 <array> >byte-array [ stored-deflate inflate ] keep = ] unit-test
{ B{ } } [ B{ } stored-deflate inflate ] unit-test

! The raw decoder stops after BFINAL and ignores padding/trailing bytes.
{ B{ } } [ B{ 3 252 99 } inflate ] unit-test
