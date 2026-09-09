! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors colors destructors fonts fonts.shaping grouping
kernel locals math math.functions sequences tools.test windows.directwrite
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
