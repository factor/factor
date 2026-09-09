! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays colors destructors fonts fonts.shaping grouping
kernel locals math math.functions sequences strings tools.test windows.directwrite
windows.directwrite.render ;
IN: windows.directwrite.render.tests

: emoji-font ( -- font ) "Segoe UI Emoji" <font> 48 >>size ;

: emoji-pixels ( font -- pixels )
    [ "\u01f600" <directwrite-layout> &dispose
      directwrite-layout>image bitmap>> 4 group ] with-destructors ;

! Check native color layers, not merely the presence of rasterized text.
{ t } [ emoji-font emoji-pixels [ first3 drop = not ] any? ] unit-test
{ f } [ emoji-font f font-with-color-fonts emoji-pixels
        [ first3 drop = not ] any? ] unit-test

! Palette glyph opacity follows the font foreground just like ordinary text.
{ 128 } [
    emoji-font 0.0 0.0 0.0 0.5 <rgba> >>foreground
    0.0 0.0 0.0 0.0 <rgba> >>background
    emoji-pixels [ fourth ] map supremum
] unit-test

:: selection-center-pixel ( layout rectangle -- rgba )
    layout directwrite-layout>image :> image
    rectangle left>> rectangle width>> 2 / + layout origin>> first + floor >integer :> x
    rectangle top>> rectangle height>> 2 / + layout origin>> second + floor >integer :> y
    image dim>> second 1 - y - image dim>> first * x + 4 * :> offset
    offset offset 4 + image bitmap>> subseq ;

! A logical selection crossing Hebrew and Latin paints both disjoint runs.
:: bidi-selection-test ( -- ? )
    [ "Segoe UI" <font> 24 >>size
      0.0 0.0 0.0 0.0 <rgba> dup [ >>foreground ] dip >>background
      "abc \u0005d0\u0005d1\u0005d2 XYZ" 1 6 1.0 0.0 0.0 0.5 <rgba> <selection>
      <directwrite-layout> &dispose :> layout
      layout directwrite-selection-rects dup length 2 =
      swap [ layout swap selection-center-pixel { 255 0 0 128 } sequence= ] all? and
    ] with-destructors
;

{ t } [ bidi-selection-test ] unit-test

! A translucent custom highlight survives the straight RGBA conversion.
{ t } [
    [ "Segoe UI" <font> 24 >>size
      0.0 0.0 0.0 0.0 <rgba> dup [ >>foreground ] dip >>background
      "abc XYZ" 0 3 1.0 0.0 0.0 0.5 <rgba> <selection>
      <directwrite-layout> &dispose directwrite-layout>image
      bitmap>> 4 group [ { 255 0 0 128 } sequence= ] any?
    ] with-destructors
] unit-test

[ emoji-font "x" <directwrite-layout> dup dispose directwrite-layout>image ]
[ already-disposed? ] must-fail-with

! Even a cached bitmap does not make a disposed native layout usable.
[
    emoji-font "x" <directwrite-layout>
    dup directwrite-layout>image drop dup dispose directwrite-layout>image
] [ already-disposed? ] must-fail-with


:: tiled-matches-native? ( font text -- ? )
    font text <directwrite-layout> [ :> layout
        layout directwrite-layout>image :> tiled
        [ layout pointer>> layout size>> layout origin>> COLOR: black COLOR: white
            render-directwrite-tile ] with-destructors :> native
        tiled dim>> native dim>> = tiled bitmap>> native bitmap>> = and
    ] with-disposal ;

! Several tiles must reproduce the same pixels as one native surface,
! including glyphs straddling a tile boundary.
{ t } [ "Consolas" <font> 1000 CHAR: a <string> tiled-matches-native? ] unit-test
{ t } [ emoji-font 50 0x1f600 <string> tiled-matches-native? ] unit-test
{ t } [ "Consolas" <font> 200 [ "a\n" ] replicate concat tiled-matches-native? ] unit-test

:: image-has-ink? ( image -- ? )
    image bitmap>> 4 group [ first3 255 < swap 255 < or swap 255 < or ] any? ;

:: long-line-renders? ( -- ? )
    "Consolas" <font> 10000 CHAR: a <string> <directwrite-layout> [ :> layout
        layout directwrite-layout>image :> image
        image dim>> layout size>> = image image-has-ink? and
    ] with-disposal ;

! The original single-surface renderer raises E_INVALIDARG for this line.
{ t } [ long-line-renders? ] unit-test

:: tail-region-renders? ( -- ? )
    "Consolas" <font> 10000 CHAR: a <string> <directwrite-layout> [ :> layout
        layout layout size>> first 128 - 0 2array
        128 layout size>> second 2array directwrite-layout>region-image
        image-has-ink? layout image>> not and
    ] with-disposal ;

! Viewport callers can rasterize the far end without allocating the full
! line image or populating its full-image cache.
{ t } [ tail-region-renders? ] unit-test

:: distant-selection-renders? ( -- ? )
    "Consolas" <font> 0 0 0 0 <rgba> dup [ >>foreground ] dip >>background
    10000 CHAR: a <string> 5000 5100 COLOR: red <selection>
    <directwrite-layout> [ :> layout
        5020 layout directwrite-offset>x layout origin>> first + floor >integer :> x
        layout x 0 2array 64 layout size>> second 2array directwrite-layout>region-image
        bitmap>> 4 group [ { 255 0 0 255 } sequence= ] any?
    ] with-disposal ;
{ t } [ distant-selection-renders? ] unit-test

[ emoji-font "x" <directwrite-layout> dup dispose
    { 0 0 } { 8 8 } directwrite-layout>region-image ]
[ already-disposed? ] must-fail-with
