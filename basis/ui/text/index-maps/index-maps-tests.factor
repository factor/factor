! Copyright (C) 2026 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays io.encodings.string io.encodings.utf16
io.encodings.utf8 kernel locals math sequences strings tools.test ui.text.index-maps ;
IN: ui.text.index-maps.tests

:: utf8-roundtrips? ( text -- ? )
    text <utf8-index-map> :> map
    text length 1 + <iota> [| i |
        i map codepoint>native dup i text >utf8-index =
        swap map native>codepoint i = and
    ] all? ;

:: utf16-roundtrips? ( text -- ? )
    text <utf16-index-map> :> map
    text length 1 + <iota> [| i |
        i map codepoint>native dup text i head utf16n encode length 2 /i =
        swap map native>codepoint i = and
    ] all? ;

{ t } [ { "" "ascii" "aλb😀c" "é日本語👩‍💻" } [ utf8-roundtrips? ] all? ] unit-test
{ t } [ { "" "ascii" "aλb😀c" "é日本語👩‍💻" } [ utf16-roundtrips? ] all? ] unit-test

{ { 0 0 1 2 } } [
    "😀x" <utf16-index-map> '[ _ native>codepoint ] { 0 1 2 3 } swap map
] unit-test

{ { 0 0 0 0 1 2 } } [
    "😀x" <utf8-index-map> '[ _ native>codepoint ] { 0 1 2 3 4 5 } swap map
] unit-test

! Ten million ASCII characters require no per-character map allocations.
{ t 9999999 9999999 } [
    10000000 CHAR: a <string> <utf16-index-map>
    [ positions>> empty? ] [ 9999999 swap codepoint>native ]
    [ 9999999 swap native>codepoint ] tri
] unit-test
