! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: tools.test core-text core-text.fonts core-foundation
core-foundation.dictionaries destructors arrays kernel
generalizations math accessors core-foundation.utilities
combinators hashtables colors ;
IN: core-text.tests

: test-font ( name -- font )
    [ >cf &CFRelease 0.0 f CTFontCreateWithName ] with-destructors ;

{ } [ "Helvetica" test-font CFRelease ] unit-test

{ } [
    [
        kCTFontAttributeName "Helvetica" test-font &CFRelease 2array 1array
        <CFDictionary> &CFRelease drop
    ] with-destructors
] unit-test

:: test-typographic-bounds ( string font -- ? )
    [
        font test-font &CFRelease :> ctfont
        string ctfont COLOR: white <CTLine> &CFRelease :> ctline
        ctfont ctline compute-line-metrics {
            [ width>> float? ]
            [ ascent>> float? ]
            [ descent>> float? ]
            [ leading>> float? ]
        } cleave and and and
    ] with-destructors ;

{ t } [ "Hello world" "Helvetica" test-typographic-bounds ] unit-test

{ t } [ "Hello world" "Chicago" test-typographic-bounds ] unit-test

{ t } [ "日本語" "Helvetica" test-typographic-bounds ] unit-test
