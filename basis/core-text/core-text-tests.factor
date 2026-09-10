! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs colors combinators continuations
core-foundation core-foundation.attributed-strings
core-foundation.dictionaries core-foundation.utilities core-graphics
core-text core-text.fonts destructors fonts generalizations
hashtables images kernel math math.order math.vectors namespaces
opengl sequences strings tools.test ;
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

:: test-long-line-region ( -- full-width? bounded? ink? )
    sans-serif-font COLOR: white >>foreground
    T{ rgba f 0 0 0 0 } >>background
    5000 CHAR: W <string> cached-line :> line
    line prepare-render
    line render-ext>> first 16384 >
    line { 20000 0 } 512 line render-ext>> second 2array render-region
    [ dim>> first 512 = ] [ bitmap>> [ zero? not ] any? ] bi ;

{ t t t } [ test-long-line-region ] unit-test

{ t } [
    sans-serif-font "     " 0 5 COLOR: blue <selection> cached-line
    dup prepare-render [ render-ext>> ] [ dim>> ] bi [ >= ] 2all?
] unit-test

:: test-italic-coverage ( -- contained? )
    sans-serif-font 24 >>size t >>italic? COLOR: white >>foreground
    T{ rgba f 0 0 0 0 } >>background
    "jfy Ág é ạ́ 日本語" cached-line :> line
    line prepare-render
    line render-ext>> first2 :> ( w h )
    line render-ext>> { 32 32 } v+ [
        dup line render-loc>> { 16 16 } v- set-text-position
        line line>> swap CTLineDraw
    ] make-bitmap-image bitmap>> :> pixels
    pixels length 4 /i <iota> [| i |
        i w 32 + mod 16 w 15 + between?
        i w 32 + /i 16 h 15 + between? and
        [ t ] [ i 4 * 3 + pixels nth zero? ] if
    ] all? ;

{ t } [ test-italic-coverage ] unit-test

:: ligature-glyph-count ( string mode -- n )
    [
        "Hoefler Text" test-font &CFRelease COLOR: white make-attributes clone :> attrs
        mode kCTLigatureAttributeName attrs set-at
        string attrs <CFAttributedString> &CFRelease
        CTLineCreateWithAttributedString &CFRelease CTLineGetGlyphCount
    ] with-destructors ;

! Verify that these fixtures actually form standard and optional ligatures.
{ { 2 1 1 } { 3 1 1 } { 3 1 1 } { 2 2 1 } } [
    "fi" "ffi" "ffl" "st"
    [ { 0 1 2 } [ ligature-glyph-count ] with map ] 4 napply
] unit-test

{ t } [
    { "é" "👩‍💻" "👨‍👩‍👧‍👦" "👍🏽" "🇺🇸" "1️⃣" "لا" }
    [ 1 ligature-glyph-count 1 = ] all?
] unit-test

:: test-bidi-selection ( -- whole-run? disjoint? reversed? cached? )
    sans-serif-font "Times" >>name 40 >>size "abc אבג def" cached-line :> line
    line 4 7 line-selection-spans :> whole
    whole length 1 = whole first first2 < and
    line 1 5 line-selection-spans :> partial
    partial length 2 = partial first second partial second first < and
    line 5 1 line-selection-spans partial =
    line 1 5 line-selection-spans partial eq? ;

{ t t t t } [ test-bidi-selection ] unit-test

{ { { 0 8 } { 10 12 } } } [
    { { 4 8 } { 0 3 } { 3 6 } { 10 12 } } merge-selection-spans
] unit-test

{ 1 } [
    sans-serif-font "abc אבג def" cached-line 0 11 line-selection-spans length
] unit-test

{ t } [
    sans-serif-font "العربية" cached-line 0 7 line-selection-spans
    [ first2 < ] all?
] unit-test

:: test-color-emoji-region ( -- identical? )
    gl-scale-factor get-global :> previous
    [
        f gl-scale-factor set-global
        sans-serif-font 700 >>size T{ rgba f 0 0 0 0 } >>background
        "👩‍💻" cached-line :> line
        line prepare-render
        line render-ext>> first :> w
        line { 0 0 } line render-ext>> render-region bitmap>> :> whole
        ! The upper part of the emoji has a negative text position in the
        ! old renderer. Compare a scanline there with the complete image.
        line { 0 0 } { 512 256 } render-region bitmap>> :> tile
        50 512 * 4 * :> tile-start
        50 w * 4 * :> whole-start
        tile-start tile-start 2048 + tile subseq
        whole-start whole-start 2048 + whole subseq =
    ] [ previous gl-scale-factor set-global ] finally ;

{ t } [ test-color-emoji-region ] unit-test

! Compare indexed drawing with Core Text drawing the complete shaped line
! into the same clipped bitmap. These lines exceed the indexing threshold.
:: native-region-pixels ( line offset dim -- pixels )
    line render-loc>> offset first
    line render-ext>> second offset second - dim second - 2array v+ :> loc
    dim [
        {
            [ line font>> dim fill-background ]
            [ loc dim line fill-selection-background ]
            [ loc first2 [ neg ] bi@ CGContextTranslateCTM ]
            [ [ line line>> ] dip CTLineDraw ]
        } cleave
    ] make-bitmap-image bitmap>> ;

:: indexed-region-test ( pattern -- ? )
    sans-serif-font "Hoefler Text" >>name 32 >>size
    T{ rgba f 0 0 0 0 } >>background
    1000 [ pattern ] replicate concat cached-line :> line
    line line>> CTLineGetGlyphCount 4096 > t assert=
    line prepare-render
    512 line render-ext>> second 2array :> dim
    { 0 512 4096 } [| x |
        line x 0 2array dim native-region-pixels
        line x 0 2array dim render-region bitmap>> =
    ] all? ;

{ t } [
    { "office ffi ạ́ " "abc אבג العربية " "👩‍💻👍🏽🇺🇸a " }
    [ indexed-region-test ] all?
] unit-test

{ t } [
    sans-serif-font COLOR: blue >>background "     " cached-line
    dup prepare-render [ render-ext>> ] [ dim>> ] bi [ >= ] 2all?
] unit-test

:: test-index-map ( string -- correct? reused? )
    sans-serif-font string cached-line :> line
    string length 1 + <iota> [| n |
        n line line-index>utf16 :> index
        index n string string-index>utf16 =
        index line utf16>line-index n = and
    ] all?
    line line-index-map line line-index-map eq? ;

{ t } [
    { "" "ASCII" "é العربية 日本語" "A😀B👩‍💻C" "😀😀😀" }
    [ test-index-map and ] all?
] unit-test

{ { 0 1 1 2 3 3 } } [
    sans-serif-font "A😀B" cached-line
    [ { -1 1 2 3 4 999 } ] dip [ utf16>line-index ] curry map
] unit-test
