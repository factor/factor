! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: tools.test core-text core-text.fonts core-foundation
core-foundation.dictionaries destructors arrays kernel
generalizations math accessors core-foundation.utilities
combinators hashtables colors continuations fonts namespaces opengl
sequences ;
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

! Identical text on 1x and 2x displays needs different rasterized lines.
! Switching back should reuse the original cache entry.
:: test-scale-cache ( -- distinct? larger? reused? )
    gl-scale-factor get-global :> original-scale
    [
        f gl-scale-factor set-global
        sans-serif-font "Retina cache" cached-line :> normal
        2.0 gl-scale-factor set-global
        sans-serif-font "Retina cache" cached-line :> retina
        normal retina eq? not
        retina dim>> first normal dim>> first >
        f gl-scale-factor set-global
        sans-serif-font "Retina cache" cached-line normal eq?
    ] [ original-scale gl-scale-factor set-global ] finally ;

{ t t t } [ test-scale-cache ] unit-test
